variable "env_name" {
  type        = string
  description = "The environment, e.g. 'production'"
  default     = "platform"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}
