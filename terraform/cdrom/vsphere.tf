variable "user" {}
variable "password" {}
variable "resource_pool_name" {}
variable "new_machine_name" {}
variable "ipv4_address" {}
variable "iso_image" {}

variable "vsphere_server" {
  default = "10.1.3.30"
}

variable "allow_unverified_ssl" {
  default = true
}

provider "vsphere" {
  user                 = "${var.user}"
  password             = "${var.password}"
  vsphere_server       = "${var.vsphere_server}"
  allow_unverified_ssl = "${var.allow_unverified_ssl}"
}

data "vsphere_datacenter" "dc_master" {
  name = "Master"
}

data "vsphere_datastore" "ds_master" {
  name          = "Datastore"
  datacenter_id = "${data.vsphere_datacenter.dc_master.id}"
}

data "vsphere_datastore" "ds_iso" {
  name          = "iso-images"
  datacenter_id = "${data.vsphere_datacenter.dc_master.id}"
}

data "vsphere_resource_pool" "rp_k598254_35" {
  name          = "${var.resource_pool_name}"
  datacenter_id = "${data.vsphere_datacenter.dc_master.id}"
}

data "vsphere_network" "nw_vm_network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc_master.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.new_machine_name}"
  resource_pool_id = "${data.vsphere_resource_pool.rp_k598254_35.id}"
  datastore_id     = "${data.vsphere_datastore.ds_master.id}"

  num_cpus = 2
  memory   = 4096
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = "${data.vsphere_network.nw_vm_network.id}"
  }

  disk {
    label = "disk0"
    size  = 32
  }

 cdrom {
    datastore_id = "${data.vsphere_datastore.ds_iso.id}"
    path = "${var.iso_image}"
 }
}
