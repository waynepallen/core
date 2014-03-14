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
#

require 'json'

class DeploymentRole < ActiveRecord::Base

  after_create :role_create_hook
  before_destroy  :role_delete_hook

  belongs_to :deployment
  belongs_to :role
  has_one    :barclamp, :through => :role
  has_many   :attribs, :through => :role

  # convenience methods

  def name
    role.name
  end

  def description
    role.description
  end

  def all_data
    role.template.deep_merge(self.data)
  end

  def data_update(val)
    DeploymentRole.transaction do
      self.data= self.data.deep_merge(val)
      save!
    end
  end

  def wall_update(val)
    DeploymentRole.transaction do
      self.wall = self.wall.deep_merge(val)
      save!
    end
  end

  private

  def role_create_hook
    role.on_deployment_create(self)
  end

  def role_delete_hook
    role.on_deployment_delete(self)
  end

end
