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

# Extend RecordNotFound to let us attach some useful error to the exception.
module ActiveRecord
  class RecordNotFound < ActiveRecordError
    attr_accessor :crowbar_model, :crowbar_column, :crowbar_key
  end
end

# This class AUTOMATICALLY extends the ActiveRecord base class 
# so that we can add AR helpers for Crowbar
module ApiHelper
#/lib/api_helper.rb

  def self.included(base)
    base.extend(ClassMethods)
    base.extend(InstanceMethods)
  end

  # for the top level classes (finders, etc)
  module ClassMethods

    # Helper to allow API to use ID or name
    def find_key(key)
      col,key = case
                when db_id?(key) then [:id, key.to_i]
                when key.is_a?(ActiveRecord::Base) then [:id, key.id]
                when self.respond_to?(:name_column) then [name_column, :key]
                else [:name, key]
                end
      begin
        find_by!(col => key)
      rescue ActiveRecord::RecordNotFound => e
        e.crowbar_model = self
        e.crowbar_column = col
        e.crowbar_key = key
        raise e
      end
    end

    # Helper to determine if a given key is an ActiveRecord DB ID
    def db_id?(key)
      key.is_a?(Fixnum) or key.is_a?(Integer) or key =~ /^[0-9]+$/
    end
  end 

  # for each instance (so we can use self)
  module InstanceMethods

  end

end
ActiveRecord::Base.send :include, ApiHelper
