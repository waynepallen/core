### CMDB APIs

CMDB APIs are used to manage configuration management databases.  

> WARNING: You cannot simply add a new CMDB type via the API!  CMDB object types must have a matching cmdb class override!  The primary function of this API is to manage the related CMDB subobjects.  You can have multiple CMDBs of the same type.

#### CMDB CRUD

List, Create, Read, Delete actions for CMDBs

> There is no update at this time!

##### List

Returns list of CMDB id:names in the system

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| GET | /2.0/crowbar/2.0/cmdb | - | - | |


**Output:**

    {
      1:"chef",
      2:"puppet",
      4:"test"
    }

Details:

* id - CMDB id
* name - CMDB name

##### Read

**Input:**

| Verb | URL | Options | Returns | Comments |2yy
|:------|:-----------------------|--------|--------|:----------------|
| GET | /2.0/crowbar/2.0/cmdb/[id] | id is the cmdb ID or name. | - | |


**Output:**

    {
      "id":4,
      "name":"chef",
      "description":null,
      "order":10000,
      "type":"CmdbChef",
      "created_at":"2012-08-13T17:20:21Z",
      "updated_at":"2012-08-13T17:20:21Z"
    }

Details:

* Format - json
* id - CMDB id
* name - CMDB name
* all Node properties serialized

##### CMDB CRUD: Create

Creates a new CMDB

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| POST | /2.0/crowbar/2.0/cmdb/ | json definition (see CMDB Show) | must be a legal object | |

**Input:**

    { 
      "name":"chef",
      "description":"description",
      "order":10000,
      "type":"CmdbChef"
    }

Details:

* name (required) - CMDB name (must be letters - numbers and start with a letter)
* description - optional (default null)
* type (required) - name of the object that manages the CMDB calls
* order - optional (default 10000) 

> The type must match an existing class in the system

##### CMDB CRUD: Delete 

Deletes a CMDB

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| DELETE  | /2.0/crowbar/2.0/cmdb/[id] | Database ID or name |  must be an existing object ID | |

No body.

**Ouptut**

None.

Details:

* id - CMDB name or database ID



