variable "bridge_domains" {
  type = map
  default = {
    aci_p01_bd_app = {
      name             = "aci_p01_bd_app"
      description      = "Application Core bridge"
      arp_flood        = "no"
      ip_learning      = "yes"
      unicast_route    = "yes"
      subnet           = "1.1.20.1/24"
      subnet_scope     = ["private"]
    },
    aci_p01_bd_web = {
      name             = "aci_p01_bd_web"
      description      = "Web/Apache Front End bridge"
      arp_flood        = "yes"
      ip_learning      = "yes"
      unicast_route    = "yes"
      subnet           = "1.1.30.1/24"
      subnet_scope     = ["private"]
    },
  }
}
variable "end_point_groups" {
  type = map
  default = {
      aci_p01_epg_web = {
          name = "aci_p01_epg_web",
          bd   = "aci_p01_bd_web"

      },
      aci_p01_epg_app = {
          name = "aci_p01_epg_app",
          bd   = "aci_p01_bd_app"
      }
  }
}