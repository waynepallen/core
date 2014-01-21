Feature: Network Ranges
  In order to manage networks, Operator
  wants to be able to add ranges

  Scenario: REST Range List
    When REST gets the {object:range} list
    Then the page returns {integer:200}

  Scenario: REST JSON check
    When REST gets 'api/v2/admin/network_ranges/admin'
    Then the {object:networkrange} is properly formatted
  