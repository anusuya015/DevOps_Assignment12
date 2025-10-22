variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
  default     = "devops-assignment"
}

variable "instance_type" {
  description = "EC2 instance type (must be free-tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "student_roll_no" {
  description = "Student roll number for identification"
  type        = string
  default     = "ITA706"
}
