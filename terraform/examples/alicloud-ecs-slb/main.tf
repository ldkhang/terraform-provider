resource "alicloud_security_group" "group" {
  name = "${var.short_name}"
  description = "New security group"
}

resource "alicloud_disk" "disk" {
  availability_zone = "${var.availability_zones}"
  category = "${var.disk_category}"
  size = "${var.disk_size}"
  count = "${var.count}"
}

resource "alicloud_instance" "instance" {
  instance_name = "${var.short_name}-${var.role}-${format(var.count_format, count.index+1)}"
  host_name = "${var.short_name}-${var.role}-${format(var.count_format, count.index+1)}"
  image_id = "${var.image_id}"
  instance_type = "${var.ecs_type}"
  count = "${var.count}"
  availability_zone = "${var.availability_zones}"
  security_groups = ["${alicloud_security_group.group.*.id}"]

  internet_charge_type = "${var.internet_charge_type}"
  internet_max_bandwidth_out = "${var.internet_max_bandwidth_out}"
  instance_network_type = "${var.instance_network_type}"

  password = "${var.ecs_password}"

  allocate_public_ip = "${var.allocate_public_ip}"

  instance_charge_type = "PostPaid"
  system_disk_category = "cloud_efficiency"


  tags {
    role = "${var.role}"
    dc = "${var.datacenter}"
  }

}

resource "alicloud_slb" "instance" {
  name = "${var.slb_name}"
  internet_charge_type = "${var.slb_internet_charge_type}"
  internet = "${var.internet}"

  listener = [
    {
      "instance_port" = "2111"
      "lb_port" = "21"
      "lb_protocol" = "tcp"
      "bandwidth" = "5"
    }]
}


resource "alicloud_disk_attachment" "instance-attachment" {
  count = "${var.count}"
  disk_id = "${element(alicloud_disk.disk.*.id, count.index)}"
  instance_id = "${element(alicloud_instance.instance.*.id, count.index)}"
  device_name = "${var.device_name}"
}


resource "alicloud_slb_attachment" "foo" {
  slb_id = "${alicloud_slb.instance.id}"
  instances = ["${alicloud_instance.instance.*.id}"]
}