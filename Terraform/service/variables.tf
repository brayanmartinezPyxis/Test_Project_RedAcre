variable services {
  type        = any 
  default     = []
  description = "all configuration for services and cluster ecs"
}

variable tags {
  type        = any
  default     = {}
  description = "description"
}

variable elb_vpc {
  type        = string
  default     = ""
  description = "VPC for ALB"
}

variable elb_subnets {
  type        = list(string)
  default     = [""]
  description = "Subnets that ALB can use"
}

variable elb_sg_ingress_rules {
  type        = any
  default     = []
  description = "description"
}
