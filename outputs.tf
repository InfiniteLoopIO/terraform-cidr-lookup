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

output "ip_count_requested" {
  description = "The number of sequential IPs to be returned in `sequential_ip_list` output list, starting with `start_ip` variable."
  value       = var.ip_count_requested
}

output "network_broadcast" {
  description = "Discovered network broadcast address."
  value       = local.ip_addresses[length(local.ip_addresses)-1]
}

output "network_cidr_suffix" {
  description = "Discovered network CIDR suffix."
  value       = local.cidr_suffix
}

output "network_host_available" {
  description = "Discovered network available host count."
  value       = length(local.ip_addresses)-2
}

output "network_host_available_first" {
  description = "Discovered network first available host address."
  value       = local.ip_addresses[1]
}

output "network_host_available_last" {
  description = "Discovered network last available host address."
  value       = local.ip_addresses[length(local.ip_addresses)-2]
}

output "network_host_total" {
  description = "Discovered network total host count."
  value       = length(local.ip_addresses)
}

output "network_id" {
  description = "Discovered network ID."
  value       = local.ip_addresses[0]
}

output "network_mask" {
  description = "Discovered network subnet mask."
  value       = local.subnet_mask
}

output "sequential_ip_list" {
  description = "A list containing sequential ip addresses within the discovered network, contains `ip_count_requested` total members starting with `start_ip` address."
  value       = local.sequential_ip_list
}

output "start_ip" {
  description = "First IP in the `sequential_ip_list` output list and index anchor when used with `ip_count_requested` variable."
  value       = var.start_ip
}

output "valid_range" {
  description = "Debug attribute, if not true than the discovered network did not have enough sequential ip addresses starting with `start_ip` index and ending (`ip_count_requested` - 1) spots away.  The `sequential_ip_list` output list is empty."
  value       = local.valid_range
}

output "valid_start_ip" {
  description = "Debug attribute, if not true than the `start_ip` variable is not within the discovered network.  The `sequential_ip_list` output list is empty."
  value       = local.valid_start_ip
}

