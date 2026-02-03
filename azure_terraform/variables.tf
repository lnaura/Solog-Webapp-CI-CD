variable "resource_group_name" {
  default = "rg-solog-project"
}

variable "location" {
  default = "Korea Central"
}

variable "suffix" {
  description = "ACR 이름 중복 방지를 위한 랜덤 접미사"
  default     = "000807"
}

variable "subscription_id" {
    description = "Azure Subscription ID"
    type        = string
}