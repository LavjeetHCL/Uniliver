variable "rgs" {
  type = map(object({
    location = string
    tags     = optional(map(string))
  }))
}
