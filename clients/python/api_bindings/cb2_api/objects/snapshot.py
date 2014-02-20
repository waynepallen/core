# Copyright 2014, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from cb2_api.endpoint import EndPoint
import json, requests
from apiobject import ApiObject

class SnapshotEP(EndPoint):    
    '''
    https://github.com/opencrowbar/core/blob/master/doc/devguide/api/snapshots.md
    '''
    __endpoint   = "/api/v2/snapshots"      
    __apiObjectType = "snapshot"
    
    def __init__(self, session):
        self.session = session
        self.endpoint = SnapshotEP.__endpoint
        super(SnapshotEP, self).__init__(session)
        
    def commit(self, snapshotID):
        '''
        Commits snapshot for action by the Annealer 
        '''
        self.endpoint = SnapshotEP.__endpoint +'/' + str(snapshotID) + "/commit"         
        URL = self.session.url + self.endpoint
        r = requests.put(URL,data={}, auth=self.Auth,headers=self.Headers)
        self.endpoint.check_response(r)
        resp = r.json()
        print "commit response : " +  str(resp)
        return resp
        
    def delete(self, snapshotID):
        print 'Delete method not supported for snapshot'
        raise NotImplementedError   
        
        
class Snapshot(ApiObject):
    '''
    Snapshot object
    
    ''' 
    
    def __init__(self, json={}):
        self.name = None
        self.created_at = None
        self.updated_at = None
        self.order = None
        self.state = None
        self.snapshot_id = None
        self.deployment_id = None
        self.id = None
        self.description = None
        self.__dict__ = json
        super(Snapshot, self).__init__()
        
        
   
class Enums_Snapshot():
    '''
    TODO
    '''
 
    
        

        