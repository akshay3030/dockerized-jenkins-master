
########
provider "aws" {
  //  access_key = "${var.aws_access_key}"
  //  secret_key = "${var.aws_secret_key}"
  #region     = "us-west-2"
  region = "${var.aws_region}"
  profile = "default"
}

resource "random_id" "server" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    #ami_id = "${var.ami_id}"
  }

  byte_length = 8
}


resource "aws_autoscaling_group" "webapp_v1" {
  #depends_on = ["aws_alb.webapp"]
  depends_on = ["aws_launch_configuration.launchWebapp"]
  name = "Webapp-${var.environment}-${var.environment_prefix}"
  default_cooldown = 600
  desired_capacity = "${var.num_nodes}"
  health_check_grace_period = 900

  launch_configuration = "${aws_launch_configuration.launchWebapp.name}"
  max_size = "${var.max_num_nodes}"
  min_size = "${var.min_num_nodes}"

  #load_balancers = ["${aws_lb.alb.id}"]
  target_group_arns = ["${aws_alb_target_group.tgHttp.arn}"]
  #availability_zones = ["${var.aws_region}a"] only works for clb


  tags = [
    {
      key                 = "Name"
      #value               = "${var.environment}.${var.environment_prefix}.${var.route53_zone_base}"
      value                = "test-jinstance"
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
  vpc_zone_identifier = ["${data.aws_subnet.private_subnet_0.id}", "${data.aws_subnet.private_subnet_1.id}","${data.aws_subnet.private_subnet_2.id}"]
  #vpc_zone_identifier = ["${data.aws_subnet.public_subnet_0.id}", "${data.aws_subnet.public_subnet_1.id}","${data.aws_subnet.public_subnet_2.id}"]

  #load_balancers = ["${aws_alb.webapp.name}"]
  #load_balancers = ["${aws_alb.webapp.id}"]
  health_check_type = "ELB"

  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]

  metrics_granularity = "1Minute"

}

resource "aws_autoscaling_policy" "autopolicy-up" {
  name = "${var.environment}-${var.environment_prefix}-autopolicy-up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.webapp_v1.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-up" {
  alarm_name = "${var.environment}-${var.environment_prefix}-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "60"
  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.webapp_v1.name}"
  }
  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.autopolicy-up.arn}"]
}


resource "aws_autoscaling_policy" "autopolicy-down" {
  name = "${var.environment}-${var.environment_prefix}-autopolicy-down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.webapp_v1.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
  alarm_name = "${var.environment}-${var.environment_prefix}-alarm-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.webapp_v1.name}"
}

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.autopolicy-down.arn}"]
}


//# Create a classic load balancer
//resource "aws_elb" "clb" {
//  name               = "webapp-clb-${var.environment_type}-${var.environment}"
//  #availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
//  subnets = ["${data.aws_subnet.public_subnet_0.id}","${data.aws_subnet.public_subnet_1.id}","${data.aws_subnet.public_subnet_2.id}"]
//  #subnets = ["${data.aws_subnet.private_subnet_0.id}", "${data.aws_subnet.private_subnet_1.id}","${data.aws_subnet.private_subnet_2.id}"]
//  security_groups = ["${aws_security_group.sgWebappElb.id}"]
//  #internal = false
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
//    ssl_certificate_id = "arn:aws:acm:us-west-2:568065941114:certificate/3d7be649-e502-4c42-9c6e-556df048afbb"
//  }
//
//  health_check {
//    healthy_threshold   = 2
//    unhealthy_threshold = 2
//    timeout             = 3
//    target              = "HTTP:80/index.html"
//    interval            = 30
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


# Use aws_alb, it's the ELB v2.   internal = false means internet facing
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  internal = true
  //depends_on = ["module.certificate"]
  #depends_on = ["aws_acm_certificate.cert"]
  name = "Webapp-${var.environment}-pub-elb"
  security_groups = ["${aws_security_group.sgWebappElb.id}"]
  #subnets = ["${data.aws_subnet.public_subnet_0.id}", "${data.aws_subnet.public_subnet_1.id}","${data.aws_subnet.public_subnet_2.id}"]
  subnets = ["${data.aws_subnet.private_subnet_0.id}", "${data.aws_subnet.private_subnet_1.id}","${data.aws_subnet.private_subnet_2.id}"]

  tags {
    #publicURL = "${aws_route53_record.record_set.name}"
    Name      = "jenkins-alb-${var.environment}-${var.environment_prefix}"
  }

}

resource "aws_alb_listener" "listenerHttps" {
  #certificate_arn = "${module.certificate.arn}"
  certificate_arn = "arn:aws:acm:us-west-2:568065941114:certificate/3d7be649-e502-4c42-9c6e-556df048afbb"

  "default_action" {
    target_group_arn = "${aws_alb_target_group.tgHttp.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_lb.alb.arn}"
  port = 443
  protocol = "HTTPS"
}

resource "aws_alb_listener" "listenerHttp" {
  #certificate_arn = "${module.certificate.arn}"

  "default_action" {
    target_group_arn = "${aws_alb_target_group.tgHttp.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_lb.alb.arn}"
  port = 80
  protocol = "HTTP"
}


resource "aws_alb_target_group" "tgHttp" {
  port = 80
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.myorg.id}"
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 60
    interval = 300
    #target = "HTTP:80/"
    protocol = "HTTP"
    #port = "80"
    #path = "/index.html"
    path = "/"
  }
}

resource "aws_alb_listener_rule" "listener_rule_http" {
  listener_arn = "${aws_alb_listener.listenerHttp.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.tgHttp.arn}"
  }

  condition {
    field  = "path-pattern"
    #values = ["/static/*"]
    values = ["/*"]

  }
//  condition {
//    field = "host-header"
//    values = ["${element(values(var.services_map), count.index)}.${var.domain}"]
//  }
}

resource "aws_alb_listener_rule" "listener_rule_https" {
  listener_arn = "${aws_alb_listener.listenerHttps.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.tgHttp.arn}"
  }

  condition {
    field  = "path-pattern"
    #values = ["/static/*"]
    values = ["/*"]

  }
  //  condition {
  //    field = "host-header"
  //    values = ["${element(values(var.services_map), count.index)}.${var.domain}"]
  //  }
}

//resource "aws_alb_listener_rule" "host_based_routing" {
//  listener_arn = "${aws_lb_listener.front_end.arn}"
//  priority     = 99
//
//  action {
//    type             = "forward"
//    target_group_arn = "${aws_lb_target_group.static.arn}"
//  }
//
//  condition {
//    field  = "host-header"
//    values = ["my-service.*.terraform.io"]
//  }
//}


resource "aws_launch_configuration" "launchWebapp" {
  #name = "Webapp-LC-${var.environment_type}-${var.environment}-${md5("${data.template_file.init.rendered}")}"
  #name = "Webapp-LC-${var.environment_type}-${var.environment}-${random_id.server.hex}"
  root_block_device {
    #device_name = "/dev/xvda"
    volume_type = "gp2"
    delete_on_termination = true
  }

  ebs_optimized = false

  iam_instance_profile = "${aws_iam_instance_profile.WebappInstanceProfile.name}"

  image_id        = "${var.ami_id}"
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
resource "aws_security_group" "sgWebappElb" {
  #name        = "webapp_elb_sg"
  description = "Security Group for 1 ELB"
  vpc_id        = "${data.aws_vpc.myorg.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

  #verify :may or may not need this
  ingress {
    security_groups = ["${aws_security_group.sgWebappElb.id}"]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  ingress {
    security_groups = ["${aws_security_group.sgWebappElb.id}"]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }

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
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes",
            "ec2:DescribeTags",
            "ec2:AttachVolume",
            "ec2:DetachVolume",
            "cloudformation:DescribeStacks",
            "kms:Decrypt",
            "sts:AssumeRole",
            "iam:GetUser",
            "iam:PassRole",
            "s3:*"
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
resource "aws_cloudwatch_log_group" "access_log_group" {
  name = "webapp-${var.environment}-access"
  retention_in_days = 5
}

//add more for api,error,access

resource "aws_cloudwatch_log_group" "error_log_group" {
  name = "webapp-${var.environment}-error"
  retention_in_days = 5
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name = "webapp-${var.environment}-api"
  retention_in_days = 5
}

resource "aws_cloudwatch_log_metric_filter" "404_metric_filter" {
  log_group_name = "${aws_cloudwatch_log_group.access_log_group.name}"
  "metric_transformation" {
    name = "Status_404"
    namespace = "WebappMetrics"
    value = "1"
  }
  name = "404_metric_filter"
  pattern = "{ $.status = 404 }"
}
resource "aws_cloudwatch_log_metric_filter" "5xx_metric_filter" {
  log_group_name = "${aws_cloudwatch_log_group.access_log_group.name}"
  "metric_transformation" {
    name = "Status_5XX"
    namespace = "WebappMetrics"
    value = "1"
  }
  name = "5xx_metric_filter"
  pattern = "{ $.status = 5* }"
}

resource "aws_cloudwatch_log_metric_filter" "2xx_metric_filter" {
  log_group_name = "${aws_cloudwatch_log_group.access_log_group.name}"


  "metric_transformation" {
    name = "Status_2XX"
    namespace = "WebappMetrics"
    value = "1"
  }
  name = "2xx_metric_filter"
  pattern = "{ $.status = 2* }"
}

resource "aws_cloudwatch_log_metric_filter" "2xx_metric_filter_bytes" {
  log_group_name = "${aws_cloudwatch_log_group.access_log_group.name}"
  "metric_transformation" {
    name = "body_bytes_sent"
    namespace = "WebappMetrics"
    value = "$.body_bytes_sent"
  }
  name = "2xx_metric_filter_bytes"
  pattern = "{ $.status = 2* }"
}


#hosted zone mapping
data "aws_route53_zone" "parent" {
  name         = "${var.route53_zone_base}."
  #private_zone = true
}

resource "aws_route53_record" "record_set" {
  zone_id = "${data.aws_route53_zone.parent.zone_id}"
  name    = "${var.environment}.${var.environment_prefix}.${var.route53_zone_base}"
  type    = "A"

  alias {
    #name                   = "dualstack.${aws_lb.alb.dns_name}"
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = false
  }
}


resource "aws_s3_bucket" "s3bucket_jenkins" {
  bucket = "s3fs-em-devops-${var.aws_region}-${var.environment_prefix}-${var.environment}"
  acl    = "private"
  #region = "${var.aws_region}"
  force_destroy = true

  tags {
    Name        = "jenkins_ec2_s3_mount"
    Environment = "${var.aws_region}"
  }
}


output "jenkins_r53_dns_name" {
  description = "The Load Balancer DNS Name"
  value = "${aws_route53_record.record_set.name}"
}

output "elb_dns_name" {
  description = "The Load Balancer DNS Name"
  value = "${aws_lb.alb.dns_name}"

}

output "jenkins_s3_bucket_name" {
  value = "${aws_s3_bucket.s3bucket_jenkins.id}"
}

output "aws_autoscaling_group" {
  value = "${aws_autoscaling_group.webapp_v1.name}"
}

