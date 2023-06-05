variable "region" {
}

variable "env" {
}


variable "service" {
}

variable "cluster" {
  default = {
    name = "test-cluster"
  }

  type = object({
    name = string
  })
}

variable "to_tag" {
  default     = ["instance", "volume"]
  description = "tags which need to implement in lauched template"
}

variable "node_group_general_purpose" {
  default = {
    name           = "general-purpose-node-group"
    instance_types = ["t3a.micro"]
    desired_size   = 1
    max_size       = 1
    min_size       = 1
  }

  type = object({
    name           = string
    instance_types = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
  })
}