
########
provider "aws" {
  //  access_key = "${var.aws_access_key}"
  //  secret_key = "${var.aws_secret_key}"
  #region     = "us-west-2"
  region = "${var.aws_region}"
  #profile = "default"
  profile = "${var.aws_profile}"
}

resource "random_id" "server" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    #ami_id = "${var.ami_id}"
  }

  byte_length = 8
}


resource "aws_autoscaling_group" "webapp_v1" {
  
  #below will create a new autoscaling group everytime an update is made to asg(or launch configuration changes)
  #name_prefix = "Webapp-${var.environment}-${var.environment_prefix}-"

  #name_prefix = "jenkins-ebs-co-${var.environment}-${var.environment_prefix}-${aws_launch_configuration.launchWebapp.name}-"

  name = "jenkins-ebs-co-${var.environment}-${var.environment_prefix}-${aws_launch_configuration.launchWebapp.name}"

  #depends_on = ["aws_alb.webapp"]
  depends_on = ["aws_launch_configuration.launchWebapp"]
  #name = "Webapp-${var.environment}-${var.environment_prefix}"
  default_cooldown = 300
  desired_capacity = "${var.num_nodes}"
  health_check_grace_period = 600

  launch_configuration = "${aws_launch_configuration.launchWebapp.name}"
  max_size = "${var.max_num_nodes}"
  min_size = "${var.min_num_nodes}"

  #load_balancers = ["${aws_elb.clb.id}"]
  #target_group_arns = ["${aws_alb_target_group.tgHttp.arn}"]
  availability_zones = ["${var.aws_region}${var.availibity_zone_suffix}"]
  vpc_zone_identifier = ["${data.aws_subnet.private_subnet_0.id}"]

  tags = [
    {
      key                 = "Name"
      #value               = "${var.environment}.${var.environment_prefix}.${var.route53_zone_base}"
      value                = "test-instance-clb"
      propagate_at_launch = true
    },
    {
      key                 = "Backup"
      value               = "${var.environment == "dev" ? 1 : 3}"  # if IsDevelopment 1, else 3
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "webappv1"
      propagate_at_launch = true
    },
    {
      key                 = "Department"
      value               = "DevOps Eng"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "${var.environment}-${var.environment_prefix}"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "devops@xxx.com"
      propagate_at_launch = true
    },
    {
      key                 = "Cost Center"
      value               = "CS123"
      propagate_at_launch = true
    },
    {
      key                 = "Compliance"
      value               = "No-PII"
      propagate_at_launch = true
    }
  ]


//  target_group_arns = ["${aws_alb_target_group.tgWebappHttp.arn}", "${aws_alb_target_group.tgWebappHttps.arn}"]
  //target_group_arns = ["${aws_alb_target_group.tgWebappHttps.arn}"]

  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]
  #vpc_zone_identifier = ["${data.aws_subnet.public_subnet_0.id}", "${data.aws_subnet.public_subnet_1.id}","${data.aws_subnet.public_subnet_2.id}"]

  #load_balancers = ["${aws_alb.webapp.name}"]
  #load_balancers = ["${aws_alb.webapp.id}"]
  health_check_type = "ELB"

  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]

  metrics_granularity = "1Minute"

//removing it as it's causing issue with external ebs volume attachment saying volume is already attached to another instance
//  lifecycle {
//    create_before_destroy = true
//  }

}

//resource "aws_autoscaling_policy" "autopolicy-up" {
//  name = "${var.environment}-${var.environment_prefix}-autopolicy-up"
//  scaling_adjustment = 1
//  adjustment_type = "ChangeInCapacity"
//  cooldown = 300
//  autoscaling_group_name = "${aws_autoscaling_group.webapp_v1.name}"
//}

//resource "aws_cloudwatch_metric_alarm" "cpualarm-up" {
//  alarm_name = "${var.environment}-${var.environment_prefix}-alarm-up"
//  comparison_operator = "GreaterThanOrEqualToThreshold"
//  evaluation_periods = "2"
//  metric_name = "CPUUtilization"
//  namespace = "AWS/EC2"
//  period = "120"
//  statistic = "Average"
//  threshold = "60"
//  dimensions {
//    AutoScalingGroupName = "${aws_autoscaling_group.webapp_v1.name}"
//  }
//  alarm_description = "This metric monitor EC2 instance cpu utilization"
//  alarm_actions = ["${aws_autoscaling_policy.autopolicy-up.arn}"]
//}


//resource "aws_autoscaling_policy" "autopolicy-down" {
//  name = "${var.environment}-${var.environment_prefix}-autopolicy-down"
//  scaling_adjustment = -1
//  adjustment_type = "ChangeInCapacity"
//  cooldown = 300
//  autoscaling_group_name = "${aws_autoscaling_group.webapp_v1.name}"
//}
//
//resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
//  alarm_name = "${var.environment}-${var.environment_prefix}-alarm-down"
//  comparison_operator = "LessThanOrEqualToThreshold"
//  evaluation_periods = "2"
//  metric_name = "CPUUtilization"
//  namespace = "AWS/EC2"
//  period = "120"
//  statistic = "Average"
//  threshold = "10"
//
//  dimensions {
//    AutoScalingGroupName = "${aws_autoscaling_group.webapp_v1.name}"
//}
//
//  alarm_description = "This metric monitor EC2 instance cpu utilization"
//  alarm_actions = ["${aws_autoscaling_policy.autopolicy-down.arn}"]
//}


//# Create a classic load balancer
//resource "aws_elb" "clb" {
//  name               ="jenkins-clb-${var.environment}-${var.environment_prefix}"
//  #availability_zones = ["${var.aws_region}a"]
//  #subnets = ["${data.aws_subnet.public_subnet_0.id}","${data.aws_subnet.public_subnet_1.id}","${data.aws_subnet.public_subnet_2.id}"]
//  #subnets = ["${data.aws_subnet.private_subnet_0.id}", "${data.aws_subnet.private_subnet_1.id}","${data.aws_subnet.private_subnet_2.id}"]
//  subnets = ["${data.aws_subnet.private_subnet_0.id}"]
//  security_groups = ["${aws_security_group.sgWebappElb.id}"]
//  internal = true
//
////  access_logs {
////    bucket        = "foo"
////    bucket_prefix = "bar"
////    interval      = 60
////  }
//
//  listener {
//    instance_port     = 80
//    instance_protocol = "http"
//    lb_port           = 80
//    lb_protocol       = "http"
//  }
//
//  listener {
//    instance_port      = 80
//    instance_protocol  = "http"
//    lb_port            = 443
//    lb_protocol        = "https"
//    #ssl_certificate_id = "arn:aws:acm:us-west-2:568065941114:certificate/3d7be649-e502-4c42-9c6e-556df048afbb"
//    #ssl_certificate_id  = "arn:aws:acm:us-west-2:568065941114:certificate/54415211-3614-4587-bd0e-36f5321600b4"
//    ssl_certificate_id = "${data.aws_acm_certificate.jenkins_acm.arn}"
//  }
//
//  health_check {
//    #all times in seconds
//    healthy_threshold   = 2
//    unhealthy_threshold = 5
//    timeout             = 3
//    #target              = "HTTP:80/index.html"
//    target              = "HTTP:80/"
//    interval            = 15
//  }
//
//  #instances                   = ["${aws_instance.foo.id}"]
//  cross_zone_load_balancing   = true
//  idle_timeout                = 400
//  connection_draining         = true
//  connection_draining_timeout = 400
//
//  tags {
//    Name = "webapp-elb"
//  }
//}


resource "aws_launch_configuration" "launchWebapp" {
  #name = "Webapp-LC-${var.environment_type}-${var.environment}-${md5("${data.template_file.init.rendered}")}"
  #name = "Webapp-LC-${var.environment_type}-${var.environment}-${random_id.server.hex}"
  root_block_device {
    #device_name = "/dev/xvda"
    volume_type = "gp2"
    delete_on_termination = true
    volume_size = "24"
  }

  ebs_optimized = false

  iam_instance_profile = "${aws_iam_instance_profile.WebappInstanceProfile.name}"

  image_id        = "${data.aws_ami.amazon-linux-2.id}"
  enable_monitoring = true
  instance_type   = "${var.ec2_instance_type}"
  key_name = "${var.ec2_keypair_name}"
  placement_tenancy = "default"
  security_groups = ["${aws_security_group.sgWebappEc2.id}"]

  user_data = "${data.template_file.init.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# A security group for the ELB so it is accessible via the web
//resource "aws_security_group" "sgWebappElb" {
//  #name        = "webapp_elb_sg"
//  description = "Security Group for 1 ELB"
//  vpc_id        = "${data.aws_vpc.myorg.id}"
//
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = 443
//    to_port     = 443
//    protocol    = "tcp"
//  }
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = 80
//    to_port     = 80
//    protocol    = "tcp"
//  }
//
//  egress {
//    from_port = 0
//    to_port = 0
//    protocol = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//}

# Security group for EC2 instance
resource "aws_security_group" "sgWebappEc2" {
  #name = "webapp_v1_instance_sg"
  description = "Security Group for Webapp v1 instances"
  vpc_id = "${data.aws_vpc.myorg.id}"

  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    from_port = -1
    to_port = -1
    protocol = "icmp"
  }

  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }

  #verify :may or may not need this
//  ingress {
//    security_groups = ["${aws_security_group.sgWebappElb.id}"]
//    from_port = 80
//    protocol = "tcp"
//    to_port = 80
//  }

//  ingress {
//    security_groups = ["${aws_security_group.sgWebappElb.id}"]
//    from_port = 443
//    protocol = "tcp"
//    to_port = 443
//  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_role" "WebappRole" {
  name = "${var.jenkins_v1_role_prefix}-${var.environment}-${var.environment_prefix}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Principal": {
          "Service": [
              "ec2.amazonaws.com"
          ]
      },
      "Action": [
          "sts:AssumeRole"
      ]
  }]
}
EOF

  path = "/"
}

resource "aws_iam_instance_profile" "WebappInstanceProfile" {
  path = "/"
  role = "${aws_iam_role.WebappRole.name}"
}

resource "aws_iam_policy" "root" {
  #role = "${aws_iam_role.WebappRole.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [
            "ec2:Describe*",
            "ec2:AttachVolume",
            "ec2:DetachVolume",
            "cloudformation:DescribeStacks",
            "kms:Decrypt",
            "sts:AssumeRole",
            "iam:GetUser",
            "iam:PassRole",
            "s3:*",
            "iam:ListAccountAliases",
            "route53:List*",
            "route53:Get*",
            "route53:Change*"
        ],
        "Resource": "*"
    }, {
        "Effect": "Allow",
        "Action": [
            "logs:Create*",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    }, {
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::*"
        ]
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "root_policy_attach" {
  role       = "${aws_iam_role.WebappRole.name}"
  policy_arn = "${aws_iam_policy.root.arn}"
}

/*  Ask Jonathan, what this is
  "ManagedPolicyArns": [{
                    "Fn::Sub": "arn:aws:iam::${AWS::AccountId}:policy/XlxaeInfraLoggingPolicy"
                }],
*/
//resource "aws_iam_role_policy_attachment" "log_policy_attach" {
//  role       = "${aws_iam_role.WebappRole.name}"
//  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/XlxaeInfraLoggingPolicy"
//}

//<project_name>-<environment>-<function_name>

//3 cloudwatch log groups: access, error, api
//resource "aws_cloudwatch_log_group" "access_log_group" {
//  name = "webapp-${var.environment}-access"
//  retention_in_days = 5
//}

//add more for api,error,access

//resource "aws_cloudwatch_log_group" "error_log_group" {
//  name = "webapp-${var.environment}-error"
//  retention_in_days = 5
//}

//resource "aws_cloudwatch_log_group" "api_log_group" {
//  name = "webapp-${var.environment}-api"
//  retention_in_days = 5
//}

//resource "aws_cloudwatch_log_metric_filter" "404_metric_filter" {
//  log_group_name = "${aws_cloudwatch_log_group.access_log_group.name}"
//  "metric_transformation" {
//    name = "Status_404"
//    namespace = "WebappMetrics"
//    value = "1"
//  }
//  name = "404_metric_filter"
//  pattern = "{ $.status = 404 }"
//}
//resource "aws_cloudwatch_log_metric_filter" "5xx_metric_filter" {
//  log_group_name = "${aws_cloudwatch_log_group.access_log_group.name}"
//  "metric_transformation" {
//    name = "Status_5XX"
//    namespace = "WebappMetrics"
//    value = "1"
//  }
//  name = "5xx_metric_filter"
//  pattern = "{ $.status = 5* }"
//}

//resource "aws_cloudwatch_log_metric_filter" "2xx_metric_filter" {
//  log_group_name = "${aws_cloudwatch_log_group.access_log_group.name}"
//
//
//  "metric_transformation" {
//    name = "Status_2XX"
//    namespace = "WebappMetrics"
//    value = "1"
//  }
//  name = "2xx_metric_filter"
//  pattern = "{ $.status = 2* }"
//}

//resource "aws_cloudwatch_log_metric_filter" "2xx_metric_filter_bytes" {
//  log_group_name = "${aws_cloudwatch_log_group.access_log_group.name}"
//  "metric_transformation" {
//    name = "body_bytes_sent"
//    namespace = "WebappMetrics"
//    value = "$.body_bytes_sent"
//  }
//  name = "2xx_metric_filter_bytes"
//  pattern = "{ $.status = 2* }"
//}


#hosted zone mapping
//data "aws_route53_zone" "parent" {
//  name         = "${var.route53_zone_base}."
//  #private_zone = true
//}

//resource "aws_route53_record" "record_set" {
//  zone_id = "${data.aws_route53_zone.parent.zone_id}"
//  name    = "${var.environment}.${var.environment_prefix}.${var.route53_zone_base}"
//  type    = "A"
//
//  alias {
//    #name                   = "dualstack.${aws_lb.alb.dns_name}"
//    name                   = "${aws_elb.clb.dns_name}"
//    zone_id                = "${aws_elb.clb.zone_id}"
//    evaluate_target_health = false
//  }
//}

resource "aws_ebs_volume" "ebs_jenkins" {
  availability_zone = "${var.aws_region}${var.availibity_zone_suffix}"
  type              = "gp2"
  encrypted         = true
  size              = "${var.ebs_size_gb}"
  tags {
    Name = "${var.environment}-${var.environment_prefix}-ebs-vol"
  }
}

//resource "aws_volume_attachment" "ebs_att" {
//  device_name = "/dev/xvdb"
//  volume_id   = "${aws_ebs_volume.ebs_jenkins.id}"
//  instance_id = "${aws_instance.id}"
//}

//output "jenkins_r53_dns_name" {
//  description = "The Load Balancer DNS Name"
//  value = "${aws_route53_record.record_set.name}"
//}

//output "elb_dns_name" {
//  description = "The Load Balancer DNS Name"
//  value = "${aws_elb.clb.dns_name}"
//
//}
  
output "jenkins_url" {
  value = "http://${var.environment}.${var.environment_prefix}.${var.route53_zone_base}"
}
  
output "jenkins_ebs_volume_id" {
  value = "${aws_ebs_volume.ebs_jenkins.arn}"
}

output "aws_autoscaling_group" {
  value = "${aws_autoscaling_group.webapp_v1.name}"
}

//output "ssl_certificate_id" {
//  value = "${data.aws_acm_certificate.jenkins_acm.arn}"
//}



