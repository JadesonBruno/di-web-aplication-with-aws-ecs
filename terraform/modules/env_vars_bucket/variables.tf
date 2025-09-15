# Global Variables
variable "project_name" {
    description = "The name of the project"
    type = string
}

variable "environment" {
    description = "The deployment environment (e.g., dev, staging, prod)"
    type = string
    default = "dev"

    validation {
        condition = contains(["dev", "staging", "prod"], var.environment)
        error_message = "Environment must be one of 'dev', 'staging', or 'prod'."
    }
}
