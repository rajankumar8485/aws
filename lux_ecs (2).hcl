locals {
  alb_vars      = read_terragrunt_config(find_in_parent_folders("alb_vars.hcl"))
  vpc_vars      = read_terragrunt_config(find_in_parent_folders("vpc_vars.hcl"))
  regional_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
 
  account_name           = local.account_vars.locals.account_name
  account_id             = local.account_vars.locals.aws_account_id
  terraform_modules_refs = local.account_vars.locals.terraform_modules_refs
  aws_region             = local.regional_vars.locals.aws_region
  region_dir             = local.regional_vars.locals.region_dir
  vpc_dir                = local.vpc_vars.locals.vpc_dir
  alb_dir                = local.alb_vars.locals.alb_dir
  parent_dir = "${get_terragrunt_dir()}/.."

  # Infer the stack name from the directory name e.g. 'test2' note this does *not* include the 'clbec-' prefix although in this module it is added below
  stack_name = "${basename(dirname(get_terragrunt_dir()))}"

}

remote_state {
  backend = "s3"
  config = {
    bucket         = "clbec-terraform-state-${local.account_name}"
    key            = "clbec-infra/${path_relative_to_include()}/${basename(get_terragrunt_dir())}.tfstate"
    dynamodb_table = "clbec-terraform-state-${local.account_name}"
    region         = "us-east-1"
    encrypt        = true
    role_arn       = "arn:aws:iam::${local.account_id}:role/clbec-${local.account_name}-terraform-operator"
  }
  generate = {
    path      = "backend.auto.tf"
    if_exists = "overwrite"
  }
}


generate "provider" {
  path      = "provider.auto.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  alias               = "prod"
  region              = "us-east-1"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["719910336980"]
  assume_role {
    role_arn = "arn:aws:iam::719910336980:role/clbec-current-version-reader"
  }
}

provider "aws" {
  alias               = "metadata"
  region              = "us-east-1"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
  assume_role {
    role_arn = "arn:aws:iam::${local.account_id}:role/clbec-${local.account_name}-terraform-operator"
  }
}

provider "aws" {
  region              = "${local.aws_region}"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
  assume_role {
    role_arn = "arn:aws:iam::${local.account_id}:role/clbec-${local.account_name}-terraform-operator"
  }
}
EOF
}

generate "terraform.rc" {
  path      = "terraform.rc"
  if_exists = "overwrite"
  contents  = <<EOF
provider_installation {
  # See README in the providers dir for more info.
  filesystem_mirror {
    path    = "${get_parent_terragrunt_dir()}/../providers"
    include = ["*/*"]
  }
  direct {}
}
EOF
}

terraform {
    source = "C:/PH2/ecs-alb-lux/ecs-lux"
}

dependencies {
  paths = [    
    "${local.vpc_dir}/ecs_vpc"    
  ]
}

dependency "vpc" {
  config_path = "${local.vpc_dir}/ecs_vpc"
}
dependencies {
  paths = [    
    "${local.alb_dir}/bec-stacks/dev-ecs/lux_stack/lux_alb"    
  ]
}

dependency "alb-lux_microservices" {
  config_path = "${local.alb_dir}/bec-stacks/dev-ecs/lux_stack/lux_alb"
}

dependency "alb-lux_public" {
  config_path = "${local.alb_dir}/modules/public"
}

dependency "alb-lux_batch" {
  config_path = "${local.alb_dir}/modules/batch"
}

inputs = {
  
	stack_name   = "clbec-${local.stack_name}"
	vpc_id          = dependency.vpc.outputs.vpc_id
  region     = local.aws_region
	port_eighty = 80
	memory = 1024
	cpu = 512
	names = ["aggregate", "logs", "public-endpoint", "device", "reports", "results", "batch"]

  ph2-poc-short-name = "ph2-poc"
	task_role_name = "ph2-poc-ecs-task-role"
	execution_role_name = "ecsTaskExecutionRole"
	
	inbound_custom_tcp_port_from = 5000
	inbound_custom_tcp_port_to = 5020
	enable_container_insights = true
	deployment_maximum_percent = 100
	deployment_minimum_healthy_percent = 200
	
	environment = "stage"
	rmq_engine_type = "RabbitMQ"
	rmq_engine_version = "3.9.16"
	rmq_host_instance_type = "mq.m5.large"
	
  alb-lux_batch = alb-lux_batch.outputs.load_balancer_target_grp_arn
  alb-lux_microservices = dependency.alb-lux_microservices.outputs.load_balancer_target_grp_arn
  alb-lux_public = alb-lux_public.outputs.load_balancer_target_grp_arn
	
  Billing    = "CloudBEC-${title(local.account_name)}"
	account    = local.account_name
	region     = local.aws_region
	vpc_name   = local.vpc_fullname
	alb_name   = local.alb_fullname
  stack_name = local.stack_name
	tags = "lux-dev6"
    
}

