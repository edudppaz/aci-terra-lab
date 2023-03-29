provider "aci" {
    username = "admin"
    password = "cisco.123"
    url      = "http://10.0.226.41"
    insecure = true
}
resource "aci_tenant" "aci_p01_tenant" {
  name             = "aci_p01_tenant"
}
resource "aci_vrf" "aci_p01_vrf" {
  tenant_dn         = aci_tenant.aci_p01_tenant.id
  name              = "aci_p01_vrf"
}
resource "aci_bridge_domain" "aci_p01_bridges" {
    for_each = var.bridge_domains
    tenant_dn             = aci_tenant.aci_p01_tenant.id
    relation_fv_rs_ctx    = aci_vrf.aci_p01_vrf.id
    name                  = each.value.name
    arp_flood             = each.value.arp_flood
    ip_learning           = each.value.ip_learning
    unicast_route         = each.value.unicast_route
}

resource "aci_subnet" "aci_p01_subnets" {
    for_each             = var.bridge_domains
    parent_dn            = aci_bridge_domain.aci_p01_bridges[each.key].id
    ip                   = each.value.subnet
    scope                = each.value.subnet_scope
}
resource "aci_application_profile" "aci_p01_ap" {
  tenant_dn         = aci_tenant.aci_p01_tenant.id
  name              = "aci_p01_ap"
}
resource "aci_contract" "aci_p01_con" {
  tenant_dn                 = aci_tenant.aci_p01_tenant.id
  name                        = "aci_p01_con"
 }

 resource "aci_contract_subject" "aci_p01_sub" {
   contract_dn                  = aci_contract.aci_p01_con.id
   name                         = "aci_p01_sub"
   relation_vz_rs_subj_filt_att = [aci_filter.allow_icmp.id]
 }

 resource "aci_filter" "allow_icmp" {
   tenant_dn = aci_tenant.aci_p01_tenant.id
   name      = "allow_icmp"
 }

 resource "aci_filter_entry" "icmp" {
   name        = "icmp"
   filter_dn   = aci_filter.allow_icmp.id
   ether_t     = "ip"
   prot        = "icmp"
   stateful    = "yes"
 }
 resource "aci_application_epg" "aci_p01_end_point_groups" {
  for_each = var.end_point_groups

  application_profile_dn  = aci_application_profile.aci_p01_ap.id
  name                    = each.value.name
  relation_fv_rs_bd       = aci_bridge_domain.aci_p01_bridges[each.value.bd].id
  relation_fv_rs_cons     = [aci_contract.aci_p01_con.id]
  relation_fv_rs_prov     = [aci_contract.aci_p01_con.id]
}