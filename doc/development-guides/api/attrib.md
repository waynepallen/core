### Attribute (aka Attrib) APIs

Attribute APIs are used to manage attributes tracked by the CMDB system

> To prevent Rails name collisions, OpenCrowbar uses 'Attrib' instead of Attribute.

#### Attrib CRUD

List, Create, Read, Delete actions for Attribute

> There is no update at this time!

##### List

Returns list of Attrib id:names in the system

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| GET | /2.0/crowbar/2.0/attrib | - | - | |


**Output:**

    {
      1:"ram",
      2:"cpu",
      4:"nics"
    }

Details:

* id - Attrib id
* name - Attrib name

##### Read

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| GET | /2.0/crowbar/2.0/attrib/[id] | id is the Attrib ID or name. | - | |


**Output:**

    {
      "id":4,
      "name":"ram",
      "description":null,
      "order":10000,
      "barclamp_id":40,
      "hint":null,
      "created_at":"2012-08-13T17:20:21Z",
      "updated_at":"2012-08-13T17:20:21Z"
    }

Details:

* Format - json
* id - Attrib id
* name - Attrib name
* barclamp_id - relation with barclamp (attribute only has 1)
* hint - helps the barclamp figure out how to populate the attribute.  should be assigned by the attribute

##### Attrib CRUD: Create

Creates a new Attrib

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| POST | /2.0/crowbar/2.0/attrib/ | json definition (see Attrib Show) | must be a legal object |

**Input:**

    { 
      "name":"chef",
      "description":"description",
      "order":10000,
    }

Details:

* name (required) - Attrib name (must be letters - numbers and start with a letter)
* description - optional (default null)
* order - optional (default 10000) 

##### Attrib CRUD: Delete 

Deletes an Attrib

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| DELETE | /2.0/crowbar/2.0/attrib/[id] | Database ID or name | must be an existing object ID | |

No body.

**Ouptut**

None.

Details:

* id - Attrib name or database ID



