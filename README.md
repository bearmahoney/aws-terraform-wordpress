### Overview
A terraform package consisting of one web servers sitting behind an alb in a private subnet, the private subnets still have external connectivity due to nat gateways.

## Operations
Init / validate and create/apply config:
`terraform init && terraform validate && terraform apply`

Generate resouces with the prod cert being created:
`terraform validate && terraform apply -var="prod_cert=true"`

To delete/destroy a specifc resource:
`terraform destroy -target aws_instance.wordpress_server`

To delete/destroy all resources:
`terraform destroy`

##TODO
#Move instance count to a var and change associated resources to support multiple instances
#Implement some form of certificate renewal
#Implement more prod switches for resources such as the rds instance (adding final snapshot for prod)
#Add autoscaling group to replace failed instances
#Add cloudwatch logging or some form of centralized logging
