peering_map = [
    {
        cidr_block = ""
        cidr_name  = "atlas-cidr1"
    },
    {
        cidr_block = ""
        cidr_name  = "atlas-cidr1"
    }
]

for_each = {for key in local.peering_map : key.cidr_name => key}

variable "peering_map" {
  type = list(map(string))
  description = "map for peering connections"
  default = []
}