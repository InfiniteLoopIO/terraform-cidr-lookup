terraform {
  
  required_providers {
    null  = { source = "hashicorp/null" }
    local = { source = "hashicorp/local" }
  }
  
}


provider "null"  {}
provider "local" {}
