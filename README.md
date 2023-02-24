# Terraform CIDR Lookup

This Terraform module will lookup CIDR network details and output a `sequential_ip_list` which can be useful in environments where DHCP is not enabled for all VLANs but you want to create resources using count and have a known block of free IP addresses.


## Additional Software Requirement

> Note: to discover network details for subnets with greater than [1024 hosts](https://developer.hashicorp.com/terraform/language/functions/range) a powershell helper script is being used.

- Powershell 7
  - [windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
  - [linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux)

## Usage

Once the module has been called, and assuming valid host range, use the module.cidr_lookup.sequential_ip_list output to assign discovered IPs via `module.cidr_lookup.sequential_ip_list[count.index]`

**Basic**
```hcl
module cidr_lookup {
  source             = <path to module>
  
  cidr_network       = "10.0.0.0/24"
}
```

**Advanced**
```hcl
module cidr_lookup {
  source             = <path to module>
  
  cidr_network       = "10.1.1.0/24"
  start_ip           = "10.1.1.201"
  ip_count_requested = 5
}
```

## Example Output - for_each used to call module, cidr_network as key

**Small network lookup, single IP**
```hcl
cidr_lookup = {
  "10.0.0.0/24" = {
    "ip_count_requested" = 1
    "network_broadcast" = "10.0.0.255"
    "network_cidr_suffix" = "24"
    "network_host_available" = 254
    "network_host_available_first" = "10.0.0.1"
    "network_host_available_last" = "10.0.0.254"
    "network_host_total" = 256
    "network_id" = "10.0.0.0"
    "network_mask" = "255.255.255.0"
    "sequential_ip_list" = tolist([
      "10.0.0.1",
    ])
    "start_ip" = tostring(null)
    "valid_range" = true
    "valid_start_ip" = true
  }
}
```

**Large network lookup, multiple IP**
```hcl
cidr_lookup = {
  "172.20.0.0/20" = {
    "ip_count_requested" = 5
    "network_broadcast" = "172.20.15.255"
    "network_cidr_suffix" = "20"
    "network_host_available" = 4094
    "network_host_available_first" = "172.20.0.1"
    "network_host_available_last" = "172.20.15.254"
    "network_host_total" = 4096
    "network_id" = "172.20.0.0"
    "network_mask" = "255.255.240.0"
    "sequential_ip_list" = tolist([
      "172.20.10.11",
      "172.20.10.12",
      "172.20.10.13",
      "172.20.10.14",
      "172.20.10.15",
    ])
    "start_ip" = "172.20.10.11"
    "valid_range" = true
    "valid_start_ip" = true
  }
}
```

**Small network lookup across standard subnet boundary, multiple IP**
```hcl
cidr_lookup = {
  "192.168.0.0/23" = {
    "ip_count_requested" = 5
    "network_broadcast" = "192.168.1.255"
    "network_cidr_suffix" = "23"
    "network_host_available" = 510
    "network_host_available_first" = "192.168.0.1"
    "network_host_available_last" = "192.168.1.254"
    "network_host_total" = 512
    "network_id" = "192.168.0.0"
    "network_mask" = "255.255.254.0"
    "sequential_ip_list" = tolist([
      "192.168.0.253",
      "192.168.0.254",
      "192.168.0.255",
      "192.168.1.0",
      "192.168.1.1",
    ])
    "start_ip" = "192.168.0.253"
    "valid_range" = true
    "valid_start_ip" = true
  }
}
```

**Invalid start_ip**
```hcl
cidr_lookup = {
  "10.1.1.0/24" = {
    "ip_count_requested" = 1
    "network_broadcast" = "10.1.1.255"
    "network_cidr_suffix" = "24"
    "network_host_available" = 254
    "network_host_available_first" = "10.1.1.1"
    "network_host_available_last" = "10.1.1.254"
    "network_host_total" = 256
    "network_id" = "10.1.1.0"
    "network_mask" = "255.255.255.0"
    "sequential_ip_list" = []
    "start_ip" = "10.10.10.1"
    "valid_range" = false
    "valid_start_ip" = false
  }
}
```

**Valid start_ip, invalid end range**
```hcl
cidr_lookup = {
  "10.2.2.0/24" = {
    "ip_count_requested" = 10
    "network_broadcast" = "10.2.2.255"
    "network_cidr_suffix" = "24"
    "network_host_available" = 254
    "network_host_available_first" = "10.2.2.1"
    "network_host_available_last" = "10.2.2.254"
    "network_host_total" = 256
    "network_id" = "10.2.2.0"
    "network_mask" = "255.255.255.0"
    "sequential_ip_list" = tolist([])
    "start_ip" = "10.2.2.250"
    "valid_range" = false
    "valid_start_ip" = true
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.subnet_discovery](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [local_file.subnet_discovery_canary](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_network"></a> [cidr\_network](#input\_cidr\_network) | (Required) IPv4 CIDR network in the following format x.x.x.x/x | `string` | n/a | yes |
| <a name="input_ip_count_requested"></a> [ip\_count\_requested](#input\_ip\_count\_requested) | (Optional) The total number of sequential IPs that will be discovered, starting from `start_ip` value | `number` | `1` | no |
| <a name="input_start_ip"></a> [start\_ip](#input\_start\_ip) | (Optional) The first IP to use within a CIDR network, `ip_count_requested` increments from this value.  Requestor should verify they are not using network id or broadcast for this value. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip_count_requested"></a> [ip\_count\_requested](#output\_ip\_count\_requested) | The number of sequential IPs to be returned in `sequential_ip_list` output list, starting with `start_ip` variable. |
| <a name="output_network_broadcast"></a> [network\_broadcast](#output\_network\_broadcast) | Discovered network broadcast address. |
| <a name="output_network_cidr_suffix"></a> [network\_cidr\_suffix](#output\_network\_cidr\_suffix) | Discovered network CIDR suffix. |
| <a name="output_network_host_available"></a> [network\_host\_available](#output\_network\_host\_available) | Discovered network available host count. |
| <a name="output_network_host_available_first"></a> [network\_host\_available\_first](#output\_network\_host\_available\_first) | Discovered network first available host address. |
| <a name="output_network_host_available_last"></a> [network\_host\_available\_last](#output\_network\_host\_available\_last) | Discovered network last available host address. |
| <a name="output_network_host_total"></a> [network\_host\_total](#output\_network\_host\_total) | Discovered network total host count. |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | Discovered network ID. |
| <a name="output_network_mask"></a> [network\_mask](#output\_network\_mask) | Discovered network subnet mask. |
| <a name="output_sequential_ip_list"></a> [sequential\_ip\_list](#output\_sequential\_ip\_list) | A list containing sequential ip addresses within the discovered network, contains `ip_count_requested` total members starting with `start_ip` address. |
| <a name="output_start_ip"></a> [start\_ip](#output\_start\_ip) | First IP in the `sequential_ip_list` output list and index anchor when used with `ip_count_requested` variable. |
| <a name="output_valid_range"></a> [valid\_range](#output\_valid\_range) | Debug attribute, if not true than the discovered network did not have enough sequential ip addresses starting with `start_ip` index and ending (`ip_count_requested` - 1) spots away.  The `sequential_ip_list` output list is empty. |
| <a name="output_valid_start_ip"></a> [valid\_start\_ip](#output\_valid\_start\_ip) | Debug attribute, if not true than the `start_ip` variable is not within the discovered network.  The `sequential_ip_list` output list is empty. |
<!-- END_TF_DOCS -->

## License

[Apache License, Version 2.0](LICENSE)