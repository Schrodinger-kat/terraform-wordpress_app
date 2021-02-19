
variable "project_id" {
  description = "Google Project ID"
}

variable "vpc" {
  type        = string
  description = "VPC name or self-link"
}

variable "hoenn_sub"{
  type = string
  default = "jishnn-hoenn"
}

variable "kanto_sub"{
  type = string
  default = "jishnn-kanto"
}

variable "hoenn" {
  description = "hoenn region"
  default     = "us-east1"
}

variable "kanto" {
  description = "kanto region"
  default     = "europe-west1"
}

variable "hoenn_id_cidr"{
  description="ip_cidr_range for hoenn nw"
  default = "10.0.1.0/24"
}

variable "kanto_id_cidr"{
  description="ip_cidr_range for kanto nw"
  default = "10.0.2.0/24"
}

variable "tags" {
  type = list(string)
  description = "Network tags"
  default     = ["allow-ssh","allow-http","http-server","http"]
}

# Instance Template/Group variables!

variable "mig_name" {
  type        = string
  description = "instance group name"
}

variable "base_inst" {
  type = string
  default = "jishnn-wp-migs"
}

variable "machine_type" {
  type        = string
  description = "GCP machine type"
  default     = "n1-standard-1"
}

variable "preemptible" {
  type        = bool
  description = "Preemptible VMs"
  default     = false
}

variable "rom" {
  description = "OS Image"
  default     = "debian-cloud/debian-9"
}

variable "rom_size" {
  description = "disk size in gb"
  default = "10"
}

variable "rom_type"{
  type = string
  default = "pd-ssd"
}
variable "targetsize" {
  description = "targetsize for VMs"
}

variable "load_balancer" {
  description = "loadbalancer module names"
}

#Autoscaler
variable "hoenn_as"{
  type = string
  default = "hoenn-region-autoscaler"
}

variable "kanto_as"{
  type = string
  default = "kanto-region-autoscaler"
}

variable "max" {
  description = "maximum number of replicas"
}

variable "min" {
  description = "minimum number of replicas"
}

variable "cpu_targetUtil" {
  description = "cpu utilization target for autoscale"
}
 
#Cloud SQl

variable "db_instname" {
  description = "database instance name. name persist after delete for 7 days"
}

variable "db_name" {
  description = "database name"
}

variable "usrname" {
  description = "db user name"
}

variable "passwd" {
  description = "password for db"
}
variable "db_ver" {
  type = string
  default = "MYSQL_5_6"
  
}
variable "tier"{
  type = string
  description = "sql systemtype"
  default = "db-f1-micro"
}

variable "del_prot"{
  type = bool
  description = "delete protection"
  default = false
}
