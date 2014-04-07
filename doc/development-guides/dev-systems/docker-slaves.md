## Test/Dev using Docker Worker Nodes

Crowbar developers are _strongly_ encouraged to always build and test deployment code in multi-node situations; however, this practice on VMs or physical servers has required significant computer resources.  With Docker, developers and testers can spin up a working multi-node environment much more quickly and with much lower resource requirements.  While the containerized nodes are not fully equivalent, they are more than close enough for the vast majority of deployment scenarios.  

Benefits:

* lower resources requirements on development and test systems
* much faster bring up times (no operating systems to install and boot)
* very consistent and repeatable system configuration
* good separation of nodes helps find of issues related to multi-node deployment

Not Currently Available (but expected):

* support heterogeneous Linux operating systems (important for testing)
* deploy across multiple physical nodes (import for scale)
* use of multiple NICs (converts all conduits to eth0 for now)

### Using docker-slaves with _docker-slaves_ script

> The docker-slaves script uses the docker-slave script.  They are different!
 
Wait until the admin node is up and admin node annealing is complete!

1. From the dev system, `tools/docker-slaves <number of slaves>`

This creates the number of Docker nodes requested using the Crowbar
CLI on the Admin node.  This script relies on `ssh root@172.17.0.2` to 
access the Crowbar CLI and will fail if that access is not available; however
configuring keys and ssh is part of the normal `docker-admin` script process.

It will run up to 40 of them all under Screen if
they were created successfully. 

> Detaching from the screen session will kill all the nodes!

Docker slaves is currently hard coded to only work
when the admin node is running in a container as well.

### Using Docker Slaves without the script

Please expand this section!  

The critical step is to create the node with the 'crowbar-docker-node' role.