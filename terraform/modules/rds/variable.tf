variable "env" {
  type        = string
}

variable "VPC_cidr_block" {

}
variable "infra-env" {
  description = "Type of the env eg: prod, dev, qa, or perf"
}

variable "infra-service" {
  description = "Name of the service eg: payment, pricing"
}

variable "allocated_storage" {
  default     = 50
  type        = number
  description = "Storage allocated to database instance"
}

variable "max_allocated_storage" {
  default = 2000
  type    = number
  description = "Max allocated storage"
}

variable "engine_version" {
  default     = "11.8"
  type        = string
  description = "Database engine version"
}

variable "instance_type" {
  default     = "db.t3.small"
  type        = string
  description = "Instance type for database instance"
}

variable "storage_type" {
  default     = "gp2"
  type        = string
  description = "Type of underlying storage for database ex: gp2, io1"
}

variable "iops" {
  default     = 0
  type        = number
  description = "The amount of provisioned IOPS"
}

variable "vpc_id" {
  type        = string
}

variable "database_identifier" {
  type        = string
  description = "Identifier for RDS instance"
}

variable "snapshot_identifier" {
  default     = ""
  type        = string
  description = "The name of the snapshot (if any) the database should be created from"
}

variable "skip_final_snapshot" {
  default     = true
  type        = bool
  description = "Flag to enable or disable a snapshot if the database instance is terminated"
}

variable "publicly_accessible" {
  default = false
  type    = bool
}

variable "database_name" {
  type        = string
  description = "Name of database inside storage engine"
}

variable "database_username" {
  type        = string
  description = "Name of user inside storage engine"
}

variable "database_password" {
  type        = string
  description = "Database password inside storage engine"
}

variable "database_port" {
  default     = 5432
  type        = number
  description = "Port on which database will accept connections"
}

variable "backup_retention_period" {
  default     = 7
  type        = number
  description = "Number of days to keep database backups"
}

variable "backup_window" {
  # 12:00AM-12:30AM ET
  default     = "10:00-10:30"
  type        = string
  description = "30 minute time window to reserve for backups"
}

variable "maintenance_window" {
  # SUN 12:30AM-01:30AM ET
  default     = "sun:11:00-sun:12:30"
  type        = string
  description = "60 minute time window to reserve for maintenance"
}

variable "auto_minor_version_upgrade" {
  default     = false
  type        = bool
  description = "Minor engine upgrades are applied automatically to the DB instance during the maintenance window"
}

variable "copy_tags_to_snapshot" {
  type = bool
  description = "do you want to tag snapshot of the rds"
  default = true
}

variable "multi_az" {
  type        = bool
  description = "Flag to enable hot standby in another availability zone"
}

variable "storage_encrypted" {
  default     = true
  type        = bool
  description = "Flag to enable storage encryption"
}

variable "deletion_protection" {
  default     = false
  type        = bool
  description = "Flag to protect the database instance from deletion"
}

variable "enabled_cloudwatch_logs_exports" {
  default     = true
  type        = bool
  description = "List of logs to publish to CloudWatch Logs"
}

variable "cloudwatch_logs_exports" {
  default     = ["postgresql"]
  type        = list
  description = "List of logs to publish to CloudWatch Logs"
}


variable "sg_id" {
  default = ["sg-0ff1131350b237c7e"]
  description = "security group"
  type        = list
}

variable "subnet_group" {
  type        = string
  default     = "private-rds-default-vpc"
  description = "Database subnet group"
}

variable "parameter_group" {
  default     = "custom-postgres-11"
  type        = string
  description = "Database engine parameter group"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the RDS resources"
}

variable "performance_insights_enabled" {
  default = true
  type    =  bool
}

variable "performance_insights_retention_period"{
  default = 7
  type = number
  description = "The amount of time in days to retain Performance Insights data."
}