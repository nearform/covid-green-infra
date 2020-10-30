terraform {
  required_version = ">= 0.12.29, < 0.14"

  # Providers
  required_providers {
    archive = "~> 1.3.0"
    aws     = "~> 2.70"
    null    = "~> 2.1"
    random  = "~> 2.0"
  }
}
