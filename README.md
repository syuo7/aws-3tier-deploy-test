# aws-3tier-deploy-test
Aws deploy guide for 3tier(web, was, db) architecture managed by terraform.

# Architecture Diagram
![Diagram](aws_diagram.png?raw=true "3tier Architecture Diagram")

# Description for each tf file
__main.tf__
* ``remote``, ``aws_eip``, ``aws_elb``, ``aws_key_pair`` and ``aws_instance`` resources are defined.
  * ``remote`` - Management for the tfstate on the terraform cloud. ( But current build env is local, not remote terraform build on cloud. )
  * ``aws_eip`` - Create the EIP for the Nat gateway.
  * ``aws_elb`` - Load balancing for the front of the two web instances(Nginx).
  * ``aws_key_pair`` - Public key info for ssh access to the bastion host from admin.
  * ``aws_instance`` - One Bastion host instance and two web instances. (Bastion host on the DMZ subnet, two web instances on the web subnets.)

__variables.tf__
* Some variables ( like AWS credential, CIDR,  etc) used by other tf resources.

__
