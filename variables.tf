/*
Copyright 2023 infiniteloop.io

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

variable "cidr_network" {
  type        = string
  description = "(Required) IPv4 CIDR network in the following format x.x.x.x/x"
  
  validation {
    # use this condition, and update error message, if you want to prevent large host enumeration completely
    # condition     = can(cidrnetmask(var.cidr_network)) && ( parseint(split("/", var.cidr_network)[1], 10) >= 22 )
    condition     = can(cidrnetmask(var.cidr_network))
    error_message = "Must be a valid IPv4 CIDR network with CIDR suffix >= 22.  If using CIDR suffix <= 21 you will get error due to Terraform range function artificial limitation, get-subnet.ps1 script will be invoked to get valid IP list."
  }
}

variable "start_ip" {
  type        = string
  description = "(Optional) The first IP to use within a CIDR network, `ip_count_requested` increments from this value.  Requestor should verify they are not using network id or broadcast for this value."
  default     = null

  validation {
    condition     = var.start_ip == null ? true : (length(regexall("^\\d+\\.\\d+\\.\\d+\\.\\d+$", var.start_ip)) > 0)
    error_message = "start_ip must be in the format of #.#.#.#"
  }
}

variable "ip_count_requested" {
  type        = number
  description = "(Optional) The total number of sequential IPs that will be discovered, starting from `start_ip` value"
  default     = 1
  
  validation {
    condition     = var.ip_count_requested >= 1
    error_message = "ip_count_requested must be >= 1"
  }
}
