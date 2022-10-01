variable "ns" {}

variable "app" {}

variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}

variable "tags" {
    type = object({
        Owner = string
        Environment = string
        Application = string
    })
}

variable "profile" {
  description = "AWS profile name"
}