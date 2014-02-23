### Deployment-Role API

DeploymentRoles provide the default values for node-roles in a snapshot.  They are populated from the role's template during import.

Unlike node-roles, they do not store any inbound or system data.

#### API Actions

| Verb | URL | Comments |
|:------|:-----------------------|:----------------|
| GET  | api/v2/deployment_roles | List |
| GET  | api/v2/deployment_roles/:id | Specific Item |
| PUT  | api/v2/deployment_roles/:id | Update Item |
| POST  | api/v2/deployment_roles | Create Item |
| DELETE  | - | NOT SUPPORTED |

The API includes shortcuts for 

   * deployment -> provide the name, resolved into snapshot_id of the deployment.head
   * snapshot -> provide the name, resolved into snapshot_id
   * role -> provide the name, resolved into role_id
