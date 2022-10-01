variable "app_name" {}

variable "subnets" {}

variable "registry_url" {}

variable "image_tag" {
  default = "latest"
}

variable "lb_target_id" {}
variable "lb_sg_id" {}
variable "container_port" {
  default = 80
}