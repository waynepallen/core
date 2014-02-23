### Node Role APIs

Node Roles are the core of OpenCrowbar deployment and orchestration engine

There are four types of data that OpenCrowbar tracks, three of them are maintained on related NodeRoleDatum mode.
1. user data (node_role.data) is set by users during the proposed state (also known as "out bound data")
2. system data (node_role.sysdata) is set by crowbar before annealing (also known as "out bound data")
3. wall data (node_role.wall) is set by the jig after transistion (also known as "in bound data")
4. discovery data (node.wall) is stored on the node instead of node role because it reflects node information aggregated from all the jigs.  This information is available using the node.attrib_[name] and Attrib model.  Please see the node API docs for more about this type of data

NodeRole does not have a natural key, so you must reference them them by ID or under the relenvant Nodes, Roles, or Snapshots.

#### API Actions

| Verb | URL | Comments |
|:------|:-----------------------|:----------------|
| GET  |api/v2/node_roles |List |
| GET  |api/v2/node_roles/:id |Specific Item |
| PUT  |api/v2/node_roles/:id |Update Item |
| POST  |api/v2/node_roles |Create Item |
| DELETE  |- |NOT SUPPORTED |

You must create a NodeRole in order to attach a Node to a Deployment!

Helpers have been added to NodeRole create so that you do not need to provide IDs when creating a new NodeRole.  You can pass:

* Snapshot Name instead of Snapshot ID
* Deployment Name instead of Snapshot ID (uses the Head snapshot)
* Node Name instead of Node ID
* Role Name instead of Role ID

## JSON fields

|Attribute|Type|Settable|Note|
|---------|----|--------|----|
|Available|Boolean|Yes||
|Cohort|Integer|??||
|Created_at|String|No|Unicode - date format|
|Updated_at|String|No|Unicode - date format|
|Runlog|String|??||
|Order|Integer|??||
|State|Integer|??||
|Node_Id|Integer|Yes||
|Status|??|??||
|Run_count|Integer|No||
|Snapshot_Id|Integer|??||
|Role_Id|Integer|Yes||
|Id|Internal Ref|??|Actually an Int|

