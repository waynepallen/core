# Copyright 2013, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class NetworkRange < ActiveRecord::Base
  
  validate :sanity_check_range
  
  attr_protected :id
  attr_accessible :name, :first, :last, :network_id

  belongs_to  :network
  has_many    :network_allocations,   :dependent => :destroy
  has_many    :nodes,                 :through=>:network_allocations

  alias_attribute :allocations,       :network_allocations

  def first
    IP.coerce(read_attribute("first"))
  end

  def first=(addr)
    write_attribute("first",IP.coerce(addr).to_s)
  end

  def fullname
    "#{network.name}.#{name}"
  end

  def last
    IP.coerce(read_attribute("last"))
  end

  def last=(addr)
    write_attribute("last",IP.coerce(addr).to_s)
  end

  def === (other)
    (first..last) === IP.coerce(other)
  end

  def allocate(node, suggestion = nil)
    res = NetworkAllocation.where(:node_id => node.id, :network_range_id => self.id).first
    return res if res
    if suggestion
      begin
        suggestion = IP.coerce(suggestion)
        NetworkAllocation.transaction do
          if (self === suggestion) &&
              NetworkAllocation.where(:address => suggestion.to_s).count == 0
            res = NetworkAllocation.create!(:network_range_id => self.id, :node_id => node.id, :address => suggestion)
          end
        end
      rescue
        res = nil
      end
    end
    unless res
      (first..last).each do |addr|
        next if NetworkAllocation.where(:address => addr.to_s).count > 0
        begin
          res = NetworkAllocation.create!(:network_range_id => self.id, :node_id => node.id, :address => addr.to_s)
        rescue
          res = nil
        end
        break if res
      end
    end
    network.make_node_role(node)
    res
  end

  private

  def sanity_check_range
    # Range sanity checking is easy.
    # Just make sure that the start and end are in the same subnets,
    # and that the start comes before the end.
    unless network
      errors.add("NetworkRange does not have an associated network!")
    end

    unless name
      errors.add("NetworkRange must have a name")
    end
    
    unless first.class == last.class
      errors.add("NetworkRange #{fullname}: #{first.inspect} and #{last.inspect} must be of the same type")
    end
    unless first.network == last.network
      errors.add("NetworkRange #{fullname}.#{name}: #{first.to_s} and #{last.to_s} must be in the same subnet")
    end
    if first.network == first
      errors.add("NetworkRange #{fullname}.#{name}: #{first} cannot be a subnet address")
    end
    if last.broadcast == last
      errors.add("NetworkRange #{fullname}.#{name}: #{last} cannot be a broadcast address")
    end

    # Now, verify that this range does not overlap with any other range

#    Range.transaction do
#      Range.all.each do |other|
#        if other === first
#          errors.add("Range #{fullname}: first address #{first.to_s} overlaps with range #{other.fullname}")
#        end
#        if other === last
#          errors.add("Range #{fullname}: last address #{last.to_s} overlaps with range #{other.fullname}")
#        end
#      end
#    end
  end

end
