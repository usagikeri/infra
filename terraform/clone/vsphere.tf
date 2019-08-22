variable "user" {}
variable "password" {}
variable "resource_pool_name" {}
variable "template_machine_name" {}
variable "new_machine_name" {}
variable "ipv4_address" {}

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

data "vsphere_virtual_machine" "template" {
  name          = "${var.template_machine_name}"
  datacenter_id = "${data.vsphere_datacenter.dc_master.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.new_machine_name}"
  resource_pool_id = "${data.vsphere_resource_pool.rp_k598254_35.id}"
  datastore_id     = "${data.vsphere_datastore.ds_master.id}"

  num_cpus = 2
  memory   = 4096
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id = "${data.vsphere_network.nw_vm_network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "k598254"
        domain    = "k598254.firefly.kutc.kansai-u.ac.jp"
      }

      network_interface {
        ipv4_address = "${var.ipv4_address}"
        ipv4_netmask = 16
      }

      ipv4_gateway = "10.1.3.1"
      dns_server_list = ["10.1.3.21", "10.1.3.80"]
    }
  }
}
