variable "role_mapping" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}