provider "aci" {
    username = "admin"
    password = "C1sco12345"
    url      = "https://10.10.20.14"
    insecure = true
}
# Vlan pools #

resource "aci_vlan_pool" "dynamic_pool" {
    name            =       "dynamic_vlanpool"
    description     =       "dynamic_vlanpool"
    alloc_mode      =       "dynamic"
}
resource "aci_ranges" "vlan_pool_dynamic" {
    vlan_pool_dn    =       aci_vlan_pool.dynamic_pool.id
    from            =       local.dynamic_vlan_start
    to              =       local.dynamic_vlan_end
    alloc_mode      =       "inherit"
    role            =       "external"
}

# AEP #

resource "aci_attachable_access_entity_profile" "aci_aep" {
    name            =       "EDPP_AEP"
    relation_infra_rs_dom_p =       [aci_physical_domain.edpp_physdom.id]
}

# Domains #

resource "aci_physical_domain" "edpp_physdom" {
    name            =       "edpp_physdom"
    relation_infra_rs_vlan_ns = aci_vlan_pool.dynamic_pool.id
}

# interface policy group #

resource "aci_leaf_access_port_policy_group" "aci_p01_intpolg_access" {
    name                            = "aci_p01_intpolg_access"
}
resource "aci_leaf_access_bundle_policy_group" "aci_p01_intpolg_pc" {
    name                            = "aci_p01_intpolg_pc"
}
resource "aci_leaf_access_bundle_policy_group" "aci_p01_intpolg_vpc" {
    name                            = "aci_p01_intpolg_vpc"
    lag_t                           = "node"
}
# Leaf interface selectors #
resource "aci_leaf_interface_profile" "leaf_intf_sp" {
    for_each = local.switches_data.switches
    name                            = "leaf_${each.name}_intf_p"
}
resource "aci_leaf_interface_profile" "leaf_101_102_intf_sp" {
    name                            = "leaf_101_102_intf_p"
}
# Leaf profiles #
resource "aci_leaf_profile" "leaf_101_p" {
    name                         = "leaf_101_p"
    relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.leaf_101_intf_sp.id]
}
resource "aci_leaf_profile" "leaf_102_p" {
    name                         = "leaf_102_p"
    relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.leaf_102_intf_sp.id]
}
resource "aci_leaf_profile" "leaf_101_102_p" {
    name                         = "leaf_101_102_p"
    relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.leaf_101_102_intf_sp.id]
}
# Leaf selector #
resource "aci_leaf_selector" "leaf_101_ls" {
    leaf_profile_dn         = aci_leaf_profile.leaf_101_p.id
    name                    = "leaf_101_ls"
    switch_association_type = "range"
}
resource "aci_leaf_selector" "leaf_102_ls" {
    leaf_profile_dn         = aci_leaf_profile.leaf_102_p.id
    name                    = "leaf_102_ls"
    switch_association_type = "range"
}
resource "aci_leaf_selector" "leaf_101_102_ls" {
    leaf_profile_dn         = aci_leaf_profile.leaf_101_102_p.id
    name                    = "leaf_101_102_ls"
    switch_association_type = "range"
}
resource "aci_node_block" "leaf_101_nodes" {
    switch_association_dn = aci_leaf_selector.leaf_101_ls.id
    name                  = "leaf_101_nodes"
    from_                 = 101
    to_                   = 101
}

resource "aci_node_block" "leaf_102_nodes" {
    switch_association_dn = aci_leaf_selector.leaf_102_ls.id
    name                  = "leaf_102_nodes"
    from_                 = 102
    to_                   = 102
}
resource "aci_node_block" "leaf_101_102_nodes" {
    switch_association_dn = aci_leaf_selector.leaf_101_102_ls.id
    name                  = "leaf_101_102_nodes"
    from_                 = 101
    to_                   = 102
}
# Access ports
resource "aci_access_port_selector" "access_port_selector_leaf101" {
    for_each = {
      for access_port in local.access_ports_data.leaf_101: access_port.port => access_port
    }
    leaf_interface_profile_dn = aci_leaf_interface_profile.leaf_101_intf_p.id
    description               = each.value.description
    name                      = each.value.name
    access_port_selector_type = "range"
}
resource "aci_access_port_block" "pod01_acc_port_block" {
    for_each = {
      for access_port in local.access_ports_data.leaf_101: access_port.port => access_port
    }
    access_port_selector_dn = aci_access_port_selector.access_port_selector_leaf101[each.key].id
    name                    = each.value.name
    from_port               = each.value.port
    to_port                 = each.value.port
}