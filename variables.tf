variable "project" {
  description = "Project Name"
  type        = string
  default     = "mail-triggered-test"
}

variable "apigw_stage_name" {
  type        = string
  description = "API Gateway stage name"
  # It' for test environment
  default = "test"
}
