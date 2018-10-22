# dockerized-jenkins-master-only

ENV=dev
tf plan -var-file=environments/common.tfvars -var-file=environments/${ENV}.tfvars
tf apply -var-file=environments/common.tfvars -var-file=environments/${ENV}.tfvars

jenkins_clb works fine as we can control which availablity zone ec2 will come up
jenkins_alb will either need EFS mounting(not implemented yet) or s3 mount as ec2 volume(not implemented yet)


zip -r jobs.zip jobs/