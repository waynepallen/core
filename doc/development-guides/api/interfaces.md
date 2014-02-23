### Interface (NICs) API

The Interface API is used to update the Node -> NIC Bus mapping

Lists the current networks.

**Input:**

<table border=1>
<tr><th> Verb </th><th> URL </th><th> Options </th><th> Returns </th><th> Comments </th></tr>
<tr><td> GET  </td><td>api/v2/interfaces</td><td>N/A</td><td>JSON array of Interface Mappings</td><td></td></tr>
<tr><td> POST  </td><td>api/v2/interfaces</td><td> Add new mapping </td><td> </td></tr>
<tr><td> PUT  </td><td>api/v2/interfaces/[Node Type]</td><td></td><td></td><td></td></tr>
/td></tr>
</table>

Data:

For POST/PUT use the following JSON ={"pattern"=>"node type", "bus_order"=>"0000:00/0000:00:01 | 0000:00/0000:00:03 | etc"}=

Notes:

* There is no DELETE method.
* These changes are made to the System DeploymentRole Data for the "network-server" role
