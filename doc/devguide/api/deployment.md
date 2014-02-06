# Deployment APIs

Deployments are the scope boundry for Crowbar activities on nodes-roles. They are a central component of the Crowbar data model.

The =system= deployment is a special purpose built-in deployment that cannot be edited by Crowbar users. It handles all node discovery operations.

##API Actions
|Verb |	URL |	Comments|
|-----|-----|-----------|
|GET |	api/v2/deployments |	List|
|GET |	api/v2/deployments/:id |	Specific Item|
|PUT |	api/v2/deployments/:id |	Update Item|
|POST |	api/v2/deployments |	Create Item|
|DELETE |	api/v2/deployments/:id |	Delete Item|
|GET |	api/v2/deployments/head 	|returns the current active deployment snapshot|
|GET |	api/v2/deployments/next |	returns the most recent inactive deployment snapshot|
|GET |	api/v2/deployments/:id/roles |	returns deployment_roles bound to the deployment head|

## JSON fields

|Attribute|Type|Settable|Note|
|---------|----|--------|----|
|System|Boolean|Yes||
|Snapshot_id|Internal Ref|??|Actually an Int
|Parent_id|Internal Ref|??|Actually an Int|
|Description|String|Yes||
|Name|String|Yes||
|Created_at|String|No|Unicode - date format|
|Updated_at|String|No|Unicode - date format|



