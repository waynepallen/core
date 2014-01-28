### Node APIs

Node APIs are used to manage nodes (servers) within the Crowbar system

When Nodes are created, updated or deleted, roles and jigs are notified so they can tale appropriate actions.

#### API Actions

<table border=1>
<tr><th> Verb </th><th> URL </th><th> Comments </th></tr>
<tr><td> GET  </td>
  <td> api/v2/nodes </td>
  <td> List </td></tr>
<tr><td> GET  </td>
  <td> api/v2/nodes/:id </td>
  <td> Specific Item </td></tr>
<tr><td> PUT  </td>
  <td> api/v2/nodes/:id </td>
  <td> Update Item, notifies all jigs and roles </td></tr>
<tr><td> POST </td>
  <td> api/v2/nodes </td>
  <td> Create Item, notifies all jigs and roles </td></tr>
<tr><td> DELETE </td>
  <td> api/v2/nodes/:id </td>
  <td> Delete Item + notifies all jigs and roles </td></tr>
<tr><td> GET  </td>
  <td> api/v2/nodes/:id/node_roles </td>
  <td> Shows all the roles that the node is using (including their status) </td></tr>

</table>

Details:

* name - must be FQDN


Hints: 

Uesrs can provide shortcuts to the hint data.  The following hints have been defined as optional parameters for the Node API

* ip - requests a specific network-admin IP 
* mac - setup up the DHCP resolution for the node using the given MAC address
* 

#### Examples

Using CURL to create a minimally configured node from the Admin node

  curl --digest -u 'developer:Cr0wbar!' -H "Content-Type:application/json" --url http://127.0.0.1:3000/api/v2/nodes -X POST --data @ns.json

Where the data file is =ns.json= and contains

  {
    "alive": "true", 
    "bootenv": "local",  
    "name": "test.cr0wbar.com"
  }
