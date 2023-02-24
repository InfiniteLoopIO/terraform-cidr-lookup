# display demo networks
output "cidr_lookup" {
  description = "Lookup details for all networks defined in `local.demo_list`"
  value       = module.cidr_lookup
}
