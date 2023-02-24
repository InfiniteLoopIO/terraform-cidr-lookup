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

locals {
  # resources for large networks, canary file contains path to json which houses network detail to prevent tfstate bloat
  subnet_script        = "${path.module}/resources/get-subnet.ps1"
  subnet_script_output = "${path.module}/resources/subnet_${replace(var.cidr_network, "/", "_")}.json"
  subnet_script_canary = "${path.module}/resources/subnet_${replace(var.cidr_network, "/", "_")}-canary.json"
  
  # base network detail
  cidr_suffix          = split("/", var.cidr_network)[1]
  subnet_mask          = cidrnetmask(var.cidr_network)
  
  # terraform has artificial limit of 1024 for range function, do not build host index list if network is too large
  host_numbers         = local.cidr_suffix >= 22 ? range(pow(2, 32 - local.cidr_suffix)) : []
  
  # list of ips within network, use output from get-subnet.ps1 if cidr_suffix is < 22
  ip_addresses         = local.cidr_suffix >= 22 ? [ for host_number in local.host_numbers : cidrhost(var.cidr_network, host_number) ] :  jsondecode(file(data.local_file.subnet_discovery_canary[0].content)).HostAddresses
  
  # if var.start_ip is not set return first available host ip
  start_ip             = var.start_ip != null ? var.start_ip : local.ip_addresses[1]
  
  # start and end values used to loop through local.ip_addresses
  start_index          = try( index(local.ip_addresses, local.start_ip), null )
  end_index            = local.start_index != null ? local.start_index + var.ip_count_requested : null
  
  # is start_ip valid? is range valid?
  valid_start_ip       = local.start_index != null ? true : false
  valid_range          = local.end_index   != null ? ( local.end_index < length( local.ip_addresses ) ? true : false ) : false
  
  # if range is valid build sequential list of IPs that can be used
  sequential_ip_list   = local.valid_range ? [ for i in range(local.start_index, local.end_index): local.ip_addresses[i] ] : []
}

# run get-script.ps1 for networks with more than 1024 host addresses
resource "null_resource" "subnet_discovery" {
  count = local.cidr_suffix >= 22 ? 0 : 1
  
  triggers = {
    # always_run = timestamp()
    subnet_hash = sha256("${var.cidr_network}-${local.subnet_script_output}")
  }
  
  provisioner "local-exec" {
    command     = fileexists(local.subnet_script_output) ? "write-host \"${var.cidr_network} discovery file already exists\"" : ".'${local.subnet_script}' -IP ${var.cidr_network} -jsonOutputPath '${local.subnet_script_output}' -canaryOutputPath '${local.subnet_script_canary}' "
    interpreter = ["pwsh", "-Command"]
    on_failure  = fail
  }
}

# using canary file to avoid pre-check file() function errors, contents point to json file containing network lookup details
data "local_file" "subnet_discovery_canary" {
  count = local.cidr_suffix >= 22 ? 0 : 1
  
  filename = local.subnet_script_canary 
  
  depends_on = [null_resource.subnet_discovery]
}
