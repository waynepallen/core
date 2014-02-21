## Configuration Managers (aka Jigs)

OpenCrowbar provides a pluggable model for interacting with nodes and other infrastructure.  This model is known as the "Jig" function.

The core concept is that OpenCrowbar has 1 or more Jigs that preform the work of OpenCrowbar via Jobs.

For initial OpenCrowbar work, the primary Jig is the Chef jig in Barclamp-Chef.

For testing, OpenCrowbar provides a Test Jig that is included in the core OpenCrowbar barclamp.

### Inbound path

The jig can read data from the system and store it into attributes

#### User Data
#### System Data

### Outbound path

The jig can create roles for operation

The jig can set attributes for operations

### Methods 

Each jig overrides the following core methods in OpenCrowbar

#### Create Node
Handles when a node is added to the OpenCrowbar DB.  Allows the jig to make approporate entries in it's own database

#### Delete Node
Handles when a node is removed from the OpenCrowbar DB.  Allows the jig to remove entries in it's own database

#### Run (input is list of Tacks)

