# Terraform CIDR Lookup - Demo Module

This Terraform module will demo both small and large network lookups, along with sample of mapping sequential IPs using `null_resource` local-exec output.

The objects within `demo_list` are sent to the cidr lookup module using for_each with key of `cidr_network`.  

For large networks where get-subnet.ps1 is called, fileexists() will check to see if subnet json file already exists and to avoid duplicate runs.

## Additional Software Requirement

> Note: to discover network details for subnets with greater than [1024 hosts](https://developer.hashicorp.com/terraform/language/functions/range) a powershell helper script is being used.

- Powershell 7
  - [windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
  - [linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux)


## local-exec output using various attributes returned by the cidr lookup module

**forced sequential resource creation to group output**
```hcl
null_resource.vm_instance_demo[0] (local-exec): #-------------------------#
null_resource.vm_instance_demo[0] (local-exec): name:   demo01
null_resource.vm_instance_demo[0] (local-exec): ip:     10.3.3.101
null_resource.vm_instance_demo[0] (local-exec): mask:   255.255.255.0
null_resource.vm_instance_demo[0] (local-exec): gw:     10.3.3.1
null_resource.vm_instance_demo[0] (local-exec): #-------------------------#

null_resource.vm_instance_demo[1] (local-exec): #-------------------------#
null_resource.vm_instance_demo[1] (local-exec): name:   demo02
null_resource.vm_instance_demo[1] (local-exec): ip:     10.3.3.102
null_resource.vm_instance_demo[1] (local-exec): mask:   255.255.255.0
null_resource.vm_instance_demo[1] (local-exec): gw:     10.3.3.1
null_resource.vm_instance_demo[1] (local-exec): #-------------------------#

null_resource.vm_instance_demo[2] (local-exec): #-------------------------#
null_resource.vm_instance_demo[2] (local-exec): name:   demo03
null_resource.vm_instance_demo[2] (local-exec): ip:     10.3.3.103
null_resource.vm_instance_demo[2] (local-exec): mask:   255.255.255.0
null_resource.vm_instance_demo[2] (local-exec): gw:     10.3.3.1
null_resource.vm_instance_demo[2] (local-exec): #-------------------------#
```