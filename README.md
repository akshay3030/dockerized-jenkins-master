# dockerized-jenkins-master-only

    ENV=dev
    tf plan -var-file=environments/common.tfvars -var-file=environments/${ENV}.tfvars
    tf apply -var-file=environments/common.tfvars -var-file=environments/${ENV}.tfvars
    tf destroy -var-file=environments/common.tfvars -var-file=environments/${ENV}.tfvars

jenkins_clb works fine as we can control which availablity zone ec2 will come up.

jenkins_alb will either need EFS mounting(not implemented yet) or s3 mount as ec2 volume(not implemented yet)


    zip -r jobs.zip jobs/
    

#SSH

ip=$(aws ec2 describe-instances --filters "Name=tag:Environment,Values=em-jenkins" --query "Reservations[].Instances[].PrivateIpAddress" --region us-west-2 --output text)

ssh-keygen -R $ip;ssh ec2-user@$ip -i ~/.ssh/xxops


# Terminate Jenkins EC2 from outside; by getting ip address using ec2 tags

ssh -i ~/.ssh/xxx ec2-user@$(aws ec2 describe-instances --filters "Name=tag:Environment,Values=em-jenkins" --query "Reservations[].Instances[].PrivateIpAddress" --region us-west-2 --output text)
 -t 'sudo /sbin/shutdown -h now'

    
    