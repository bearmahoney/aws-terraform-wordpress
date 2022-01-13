# Overview
A terraform package consisting of one web servers sitting behind an alb in a private subnet, the private subnets still have external connectivity due to nat gateways.

## Bootstrapping
TODO

## Operations
Init / validate and create/apply config:
`terraform init && terraform validate && terraform apply`

Generate resouces with the prod cert being created:
`terraform validate && terraform apply -var="prod_cert=true"`

Using a tfvar file:
```
cat example.tfvars
notification_email = "bear.mahoney@gmail.com"
domain = "bearmahoney.xyz"
prod_cert = true

terraform validate && terraform apply -var-file="example.tfvars"
```

To delete/destroy a specifc resource:
`terraform destroy -target aws_instance.wordpress_server`

To delete/destroy all resources:
`terraform destroy`

## Features
- HTTP redirect to HTTPs from alb level
- Monthly system updates and automatc reboot
- Email notification for healthy host failure (could indicate issues with cert/httpd service/mysql connection) and should give a good view of overall service
- Lets Encrypt SSL cert generated automagically using domain challenge (you need to own the domain and have it's name servers pointed to R53)
- Automatic system configuration and storage of certs
- Tight security; instances are only accessible by 443 to the load balancers, rds is only accessible via 3306 from instances security groups.


## TODO
- Add some form of seperation or bootstrapping so that the domain can be created prior to certificate (else dns challenge can fail due to dns propagation)
- Move instance count to a var and change associated resources to support multiple instances
- Implement some form of certificate renewal
- Implement more prod switches for resources such as the rds instance (adding final snapshot for prod)
- Add autoscaling group to replace failed instances / scaling purposes
- Add cloudwatch logging or some form of centralized logging
- Exand update script to cater for multiple instances keeping one up always as well as implementing connection draining
- Add additional updates to pull latest WP version
- Expand SG logic to use specific instance endpoints rather than overall security groups
