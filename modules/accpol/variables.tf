locals {
    static_vlan_start       = "vlan-100"
    static_vlan_end         = "vlan-149"
    dynamic_vlan_start      = "vlan-150"
    dynamic_vlan_end        = "vlan-199"
    access_ports_data       = yamldecode(file("access_topo.yml"))["access_ports"]
    port_channels_data      = yamldecode(file("access_topo.yml"))["port_channels"]
    vpc_data                = yamldecode(file("access_topo.yml"))["vpc"]

  }
