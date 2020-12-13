
resource "aws_elasticache_cluster" "memcached" {
  cluster_id                     = "elasticache"
  engine                         = "memcached"
  node_type                      = "cache.m4.large"
  num_cache_nodes                = 2
  parameter_group_name           = "default.memcached1.6"
  port                           = 11211 
  subnet_group_name              = "${aws_elasticache_subnet_group.memcachedgroup.id}"
  az_mode                        = "cross-az"
  preferred_availability_zones   = "${var.availability_zone}"
  security_group_ids             = ["${aws_security_group.private_security_group.id}"]
}



resource "aws_elasticache_subnet_group" "memcachedgroup" {
  name       = "memcachedgroup"
  subnet_ids = "${aws_subnet.private_datasubnets.*.id}"
}
