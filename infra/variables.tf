variable "resource_group_location" {
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "VirtualMachines" {
  type = list(
          object(
              {
                hostname= string
                interfaceid = string 
              }
          )
        )

  default = [
    {
        hostname= "nodemaster01",
        interfaceid = "master01"
    },
    {
        hostname= "nodeworker01",
        interfaceid = "worker01"
    }
  ]
}