% Copyright 2013, Dell 
% 
% Licensed under the Apache License, Version 2.0 (the "License"); 
% you may not use this file except in compliance with the License. 
% You may obtain a copy of the License at 
% 
%  eurl://www.apache.org/licenses/LICENSE-2.0 
% 
% Unless required by applicable law or agreed to in writing, software 
% distributed under the License is distributed on an "AS IS" BASIS, 
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
% See the License for the specific language governing permissions and 
% limitations under the License. 
% 
-module(network).
-export([step/2, validate/1, g/1, json/3, make_admin/0]).
-define(IP_RANGE, "\"host\": {\"start\":\"192.168.124.61\", \"end\":\"192.168.124.169\"}").
-include("bdd.hrl").

% This method is used to define constants
g(Item) ->
  case Item of
    path -> "network/api/v2/networks";
    _ -> crowbar:g(Item)
  end.

% Common Routine
% Makes sure that the JSON conforms to expectations (only tests deltas)
validate(JSON) when is_record(JSON, obj) ->
  J = JSON#obj.data,
  R =[JSON#obj.type == "network",
      bdd_utils:is_a(J, length, 14),
      bdd_utils:is_a(J, int, vlan),
      bdd_utils:is_a(J, boolean, use_vlan),
      bdd_utils:is_a(J, boolean, use_bridge),
      bdd_utils:is_a(J, int, team_mode),
      bdd_utils:is_a(J, boolean, use_team),
      bdd_utils:is_a(J, string, conduit),
      bdd_utils:is_a(J, str, v6prefix),
      crowbar_rest:validate(J)],
  bdd_utils:assert(R);
validate(JSON) -> 
  bdd_utils:log(error, network, validate, "requires #obj record. Got ~p", [JSON]), 
  false.

json(Name, Description, Order) ->
 crowbar:json([{name, Name}, {description, Description}, {order, Order}, {conduit, "1g0"}, {deployment, "system"}]).

% creates the core crowbar network using the bootstraping UI path
make_admin() ->
  Test = eurl:get_http(eurl:path([g(path),"admin"])),
  if Test#http.code == 404 ->
      URI = eurl:path(["utils","bootstrap"]),
      R = eurl:put_post(URI, [], post),
      bdd_utils:log(debug, network, make_admin, "Code: ~p, URL: ~p", [R#http.code, R#http.url]);
    true -> 
      bdd_utils:log(info, network, make_admin, "Network-Admin Exists, did not recreate", [])
  end.

step(_Global, {step_setup, _N, _}) -> true;

step(_Global, {step_teardown, _N, _}) -> true;

step(_Result, {_Type, _N, ["END OF CONFIG"]}) ->
  false.