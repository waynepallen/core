### Barclamp/Config APIs

#### Barclamp Config

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| GET  | /[:barclamp]/v2/configs  | none   | Config List | - | 
| POST | /[:barclamp]/v2/configs  | none   | New Config | - | 
| GET  | /[:barclamp]/v2/configs/[:config]  | none   | Existing Config Detail | - | 
| PUT  | /[:barclamp]/v2/configs/[:config]  | none   | Update Config Detail | - | 
| GET  | /[:barclamp]/v2/configs/[:config]  | none   | Existing Config Detail | - | 

Posting a new configuration will automatically clone the template instance as the proposed configuration instance for the new configuration.

> Not all barclamps allow multiple configurations!

#### Barclamp Config Actions

| Verb | URL | Options | Returns | Comments |
|:------|:-----------------------|--------|--------|:----------------|
| PUT  | /[:barclamp]/v2/configs/[:config]/commit  | none   | Commit Proposed | - | 
| PUT  | /[:barclamp]/v2/configs/[:config]/dequeue | none   | Dequeue Proposed Config | - | 
| PUT  | /[:barclamp]/v2/configs/[:config]/propose | none   | Create an new Proposal based on Active| - | 
| PUT  | /[:barclamp]/v2/configs/[:config]/transition | none   | Send Transistion Data into the system| - | 


