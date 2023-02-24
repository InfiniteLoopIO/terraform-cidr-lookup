locals {
  # discovering large networks will slow tf plan, apply, destroy, and console operations
  
  demo_list = [
    {
      description  = "simple 10.x"
      cidr_network = "10.0.0.0/24"
    },
    
    {
      description  = "simple 10.x - bad start_ip"
      cidr_network = "10.1.1.0/24"
      start_ip     = "10.10.10.1"
    },
    
    {
      description        = "simple 10.x - bad range due to ip_count_requested"
      cidr_network       = "10.2.2.0/24"
      start_ip           = "10.2.2.250"
      ip_count_requested = 10
    },
    
    {
      description        = "simple 10.x - custom start_ip"
      cidr_network       = "10.3.3.0/24"
      start_ip           = "10.3.3.101"
      ip_count_requested = 5
    },
    
    {
      desciption         = "large 10.x - get-subnet.ps1 script invoked"
      cidr_network       = "10.0.16.0/20"
      start_ip           = "10.0.15.1"
      ip_count_requested = 5
    },
    
    {
      description        = "large 172.x - get-subnet.ps1 script invoked"
      cidr_network       = "172.20.0.0/20"
      start_ip           = "172.20.10.11"
      ip_count_requested = 5
    },
    
    {
      description        = "small 192.x - cross standard vlan boundary"
      cidr_network       = "192.168.0.0/23"
      start_ip           = "192.168.0.253"
      ip_count_requested = 5
    }
  ]
  
  
  demo_vm = {
      name      = "demo"
      network   = "10.3.3.0/24"
      instances = 3
      gateway   = "first_available" // "last_available"
  }
  vm_name_suffix_base = 1
}


module cidr_lookup {
  source             = "../"
  for_each           = { for obj in local.demo_list : obj.cidr_network => obj }
  
  cidr_network       = each.value.cidr_network
  start_ip           = try(each.value.start_ip, null)
  ip_count_requested = try(each.value.ip_count_requested, 1)
}


# local exec demo using count and module output, run sequentially to group output
resource "null_resource" "vm_instance_demo_state" {
  count = local.demo_vm.instances

  triggers = {
    always_run = timestamp()
  }
  
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command = "0 > current_state.txt"
  }
}


resource "null_resource" "vm_instance_demo" {
  count = local.demo_vm.instances
  
  triggers = {
    always_run = timestamp()
  }
  
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command = <<-EOT
      while((get-content current_state.txt) -ne ${count.index}){
        write-host "SEQUENTIAL WAIT TRIGGERED - vm_instance_demo - instance ${count.index} is waiting..."
        start-sleep -s 5
      }
    EOT
  }
  
  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command = <<-EOT
      $pad  = "#$((1..25 | % {'-'}) -join '')#"
      $name = "${local.demo_vm.name}${(format( "%02d", local.vm_name_suffix_base + count.index))}"
      $ip   = "${module.cidr_lookup[local.demo_vm.network].sequential_ip_list[count.index]}"
      $mask = "${module.cidr_lookup[local.demo_vm.network].network_mask}"
      $gw   = "${local.demo_vm.gateway == "first_available" ? module.cidr_lookup[local.demo_vm.network].network_host_available_first : module.cidr_lookup[local.demo_vm.network].network_host_available_last}"
      write-host "`n$pad`nname:`t$name`nip:`t$ip`nmask:`t$mask`ngw:`t$gw`n$pad`n"
    EOT
  }
  
  provisioner "local-exec" {
      interpreter = ["pwsh", "-Command"]
      command = "${count.index+1} > current_state.txt"
  }
  
  depends_on = [ 
    module.cidr_lookup,
    null_resource.vm_instance_demo_state 
  ]
}
