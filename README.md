# aws-3tier-deploy-test
Aws deploy guide for 3tier(web, was, db) architecture managed by terraform.

# Architecture Diagram
![Diagram](aws_diagram.png?raw=true "3tier Architecture Diagram")

# Description for each tf file
__main.tf__
* ``remote``, ``aws_eip``, ``aws_elb``, ``aws_key_pair`` and ``aws_instance`` resources are defined.
  * ``remote`` - Management for the tfstate on the terraform cloud. ( But current build env is local, not remote terraform build on cloud. )
  * ``aws_eip`` - Created the EIP for the Nat gateway.
  * ``aws_elb`` - Load balancing for the front of the two web instances(Nginx).
  * ``aws_key_pair`` - Public key info for ssh access to the bastion host from admin.
  * ``aws_instance`` - One Bastion host instance and two web instances. (Bastion host on the DMZ subnet, two web instances on the web subnets.)

__variables.tf__
* Some variables ( Like AWS credential, CIDR,  etc) used by other tf resources.

__vpc-gateway.tf__
* ``aws_internet_gateway`` and ``aws_nat_gateway" resources are defined.
  * ``aws_internet_gateway`` - Internet gateway for the public dmz subnet.
  * ``aws_nat_gateway`` - NAT gateway for the private subnet (web,was,db) connects to internet via public subnet gateway (one of DMZ subnet and allocation EIP) and allocation for NAT EIP.

__vpc-route.tf__
* ``aws_route_table`` and ``aws_route_table_association`` resources are defined.
  * ``aws_route_table`` - Created the route table to each subnet (dmz,web,was,db) and each route table can be accessible to all of the external internets. ( CIDR is 0.0.0.0/0 )
``aws_route_table_association`` - Association for the routing table to each subnet.



