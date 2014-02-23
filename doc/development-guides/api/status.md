### Status APIs

Status APIs are used to provide lists of objects in optimized formats.

The general pattern for the Status API calls is:

> `status/2.0/object/[:id]`

#### Node Status 

Returns JSON for node status.  Includes hash of all nodes to help detect changes.

**Input:**

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| GET  |/status/2.0/node |none |All nodes |Used by Dashboard |
| GET  |/status/2.0/node/[id] |id is the node ID or name. Used by Node details |- |

**Output:**

    {
      "state":{"1":null},
      "sum":-1881043387,
      "i18n":{"ready":"Ready"},
      "groups":{
        "0":{"failed":0,"ready":0,"building":0,"pending":0,"unready":1,"name":"all","unknown":0}
      },
      "count":1,
      "status":{"1":"unready"}
    }

Details:

* Format - json
* i18n - the localized versions of the status strings for display.
* state - ?
* groups - ?
* status - ?
* count - ?
* sum - Hashed value of the nodes included to identify state changes for refresh
