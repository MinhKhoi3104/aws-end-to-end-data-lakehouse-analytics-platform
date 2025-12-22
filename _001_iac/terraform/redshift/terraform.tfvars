######################
# AWS Authentication #
######################
aws_region     = "ap-southeast-1"

##########################
# Application Definition # 
##########################
app_name        = "project-e2e" # Do NOT enter any spaces
app_environment = "dev" # Dev, Test, Staging, Prod, etc

#########################
# Network Configuration #
#########################
redshift_serverless_vpc_cidr      = "10.20.0.0/16"
redshift_serverless_subnet_1_cidr = "10.20.1.0/24"
redshift_serverless_subnet_2_cidr = "10.20.2.0/24"
redshift_serverless_subnet_3_cidr = "10.20.3.0/24"

###################################
## Redshift Serverless Variables ##
###################################
redshift_serverless_namespace_name      = "my-project-e2e-nsp"
redshift_serverless_database_name       = "my-project-e2e-dtb"
redshift_serverless_admin_username      = "admin"
redshift_serverless_admin_password      = "Devdata123"
redshift_serverless_workgroup_name      = "my-project-e2e-wg"
redshift_serverless_base_capacity       = 32
redshift_serverless_publicly_accessible = true
