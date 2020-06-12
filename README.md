
**AWS/TERRAFORM TEST PROJECT** 

This is a test project that creates a AWS VPC environment with an ALB and two EC2 instances running webservers (nginx & apache2) in us-east-1 (if you want to change it, you can do it in the variable.tf file)

AWS VPC:
 - 2x Public subnets
 - 2x Private subnets
 - 2x EIP (to use in the NAT GWs)
 - 2x NAT GW (one per private subnet)
 - 1x IGW
 - 2x Security groups (private and public)

AWS EC2:

 - 1x Public ALB
 - 1x Target group in the port 80 (http)
 - 1x EC2 t2.micro with apache2 
 - 1x EC2 t2.micro with nginx 


In order to use it first you need to configure yours AWS ACCESS AND SECRET KEY

In OS X

    sed -i '' 's#aws_key_change_me#YOUR_KEY_HERE#' variables.tf
    sed -i '' 's#aws_secret_change_me#YOUR_SECRET_HERE#' variables.tf


In UNIX/Linux

    sed -i 's#aws_key_change_me#YOUR_KEY_HERE#' variables.tf
    sed -i 's#aws_secret_change_me#YOUR_SECRET_HERE#' variables.tf


After that you need to initiate terraform:

    terraform init

If its everything ok, now you can run the code:

    terraform apply -auto-approve

In approximately 4 min you are be able to copy the terraform output called ***alb_dns_name*** and run it in your favourite browser. You'll see that there are 2 deferents webservers serving you the index page.

When you have finish playing with it, don't forget to destroy the whole infrastructure with:

    terraform destroy -auto-approve


