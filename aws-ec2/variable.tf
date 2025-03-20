variable "region" {
  description = "value of region"
  type = string
  default = "ap-south-1" 
}

variable "existing_key_pair" {
    description = "Name of an existing key pair to use for the instances"
    default = "aws-key1" 
}

