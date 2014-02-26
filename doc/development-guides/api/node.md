### Node APIs

Node APIs are used to manage nodes (servers) within the OpenCrowbar system

#### Node Show (all)

**Input:**



| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| GET   |  /2.0/crowbar/2.0/node |  no options  |  Specialized return |


**Output:**

    { 
      4:"greg.example.com",
      5:"rob.example.com"
    }

Details:

* json format is id: Node name

#### Node Show (single)

**Input:**


| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| GET   |  /2.0/crowbar/2.0/node/[id] |  id is the node ID or name.  |    |


**Output:**

    {
      "id":4,
      "state":null,
      "name":"greg.example.com",
      "description":null,
      "order":10000,
      ...
      "created_at":"2012-08-13T17:20:21Z",
      "updated_at":"2012-08-13T17:20:21Z"
    }

Details:

* id - Node id
* name - Node name
* all Node properties serialized

#### Node Create (API only)

Creates a new node

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| POST   |  /2.0/crowbar/2.0/node  |  json definition (see Node Show)  |  must be a legal object |

**Input:**

    {
      "name":"fqdn.example.com",
      "description":"description",
      "order":10000,
    }

Details:

* name - Node name (must be FQDN)
* description - optional (default null)
* order - optional (default 10000) 

#### Node Delete (API only)

Deletes a node

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| DELETE   |  /2.0/crowbar/2.0/node/[id]  |  Database ID or name  |  must be an existing object ID |

No body.

**Ouptut**

None.

Details:

* id - Node name or database ID (must be FQDN)

### Node Attributes

Node Attributes API is used to retrieve data about attributes that have been associated with a Node.

Typically, attribute data is populated by the CMDB system(s) based on the associations established using this API.

#### Associations

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| GET |/2.0/crowbar/2.0/node/[id]/attribute |none |List of attribute IDs and names assigned to node| |
| GET |/2.0/crowbar/2.0/node/[id]/attribute/[id] |none |Last 100 readings (Event ID + Value) | |
| POST |/2.0/crowbar/2.0/node/[id]/attribute/[id] |none |Link Attribute to Node | |
| PUT |/2.0/crowbar/2.0/node/[id]/attribute/[id] |none |405 error - Not enabled | |
| DELETE |/2.0/crowbar/2.0/node/[id]/attribute/[id] |none |Break association and remove data | |



# Node API

Node APIs are used to manage nodes (servers) within the Crowbar system

When Nodes are created, updated or deleted, roles and jigs are notified so they can tale appropriate actions.

## API Actions
|Verb |	URL |	Comments|
|-----|-----|-----------|
|GET |	api/v2/nodes |	List|
|GET |	api/v2/nodes/:id |	Specific Item|
|PUT 	|api/v2/nodes/:id 	|Update Item, notifies all jigs and roles|
|POST |	api/v2/nodes |	Create Item, notifies all jigs and roles|
|DELETE |	api/v2/nodes/:id |	Delete Item + notifies all jigs and roles|
|GET |	api/v2/nodes/:id/node_roles |	Shows all the roles that the node is using (including their status)|

Details:

-     name - must be FQDN

Hints:

Uesrs can provide shortcuts to the hint data. The following hints have been defined as optional parameters for the Node API

-    ip - requests a specific network-admin IP
-    mac - setup up the DHCP resolution for the node using the given MAC address

## Examples

Using CURL to create a minimally configured node from the Admin node

curl --digest -u 'developer:Cr0wbar!' -H "Content-Type:application/json" --url http://127.0.0.1:3000/api/v2/nodes -X POST --data @ns.json

Where the data file is =ns.json= and contains

{ "alive": "true", "bootenv": "local",
"name": "test.cr0wbar.com" } 
## JSON Fields

| Attribute | Type |Settable | Note
|--------|--------|
| Admin       |  Boolean      |Yes||
|Alias|String|Yes||
|Alive|Boolean|Yes||
|Allocated|Boolean|Yes||
|Available|Boolean|Yes||
|Bootenv|String|Yes||
|Created_at|String|No|Unicode - date format|
|Deployment_id|Internal Ref|No|Actually an Int|
|Description|String|Yes||
|Discovery|String|Yes|All the details of the hardware - very large|
|Hint|String|Yes||
|Id|Integer|No||
|Name|String|Yes||
|Order|Integer|??||
|Target\_role_id|Internal Ref|No||
|Updated_at|String|No|Unicode - date format|


## Minimum fields needed for create

Alive, Bootenv, Name
