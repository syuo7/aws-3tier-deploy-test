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

__vpc.tf__
* ``"aws_vpc"`` resource is defined. ( VPC CIDR is ["10.10.0.0/16" )
__vpc-gateway.tf__
* ``aws_internet_gateway`` and ``aws_nat_gateway" resources are defined.
  * ``aws_internet_gateway`` - Internet gateway for the public dmz subnet.
  * ``aws_nat_gateway`` - NAT gateway for the private subnet (web,was,db) connects to internet via public subnet gateway (one of DMZ subnet and allocation EIP) and allocation for NAT EIP.

__vpc-route.tf__
* ``aws_route_table`` and ``aws_route_table_association`` resources are defined.
  * ``aws_route_table`` - Created the route table to each subnet (dmz,web,was,db) and each route table can be accessible to all of the external internets. ( CIDR is 0.0.0.0/0 )
``aws_route_table_association`` - Association for the routing table to each subnet.

__vpc-sg.tf__
* three ``aws_security_group`` resources are defined.
  * ``"aws_security_group" "elb"`` - allowed for the 80/http port to ELB node.
  * ``"aws_security_group" "threetier_default"`` - allowed for the 80/http port from the just DMZ subnets, ssh(22/tcp) access from bastion host and self(Allow all connect from the same group) ingress access.
  * ``"aws_security_group" "bastion"`` - allowed for the ssh(22/tcp) port from all nodes. (for the security, CIDR will be changing.)

__vpc-subnet.tf__
* four ``aws_subnet`` resources are defined.
  * "aws_subnet" "threetier_web_subnet" - Subnets with 10.10.0.0/24 and 10.10.1.0/24 CIDR are created for each az.
  * "aws_subnet" "threetier_dmz_subnet" - Subnets with 10.10.2.0/24 and 10.10.3.0/24 CIDR are created for each az.
  * "aws_subnet" "threetier_was_subnet" - Subnets with 10.10.10.0/24 and 10.10.11.0/24 CIDR are created for each az. (Currently, not deployed as instances, just created as a subnet)
  * "aws_subnet" "threetier_db_subnet" - Subnets with 10.10.12.0/24 and 10.10.13.0/24 CIDR are created for each az. (Currently, not deployed as instances, just created as a subnet)

__outputs.tf__
* if completed terraform deploy by ``terraform apply``, ELB DNS address will be output.

# Description for another file.
* ``script.sh`` - Provisioning for the Nginx plus install on two web instances.
* ``request.py`` - Script by python to requests and responses(save as text) to automate the dualization test of the Nginx server.

# Provision Way
1. git clone for tihs repository
2. terraform credential setting on ``variables.tf``
   * aws_access_key
   * aws_secret_key
3. If you are not the same remote terraform cloud, change your remote setting.
4. ``terraform plan``
5. ``terraform apply``
6. connect to the ELB dns address on the browser when completed deploy and refresh your browser. (Client Ip and Server Ip will be changed when refreshing (f5) a browser )
   * If you want dualization test for automatically, please use a request.py
7. ``terraform destroy`` - all of the deployed resources from terraform will be deleted on AWS.

Thanks.

