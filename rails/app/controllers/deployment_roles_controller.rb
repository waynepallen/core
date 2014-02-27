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

class DeploymentRolesController < ApplicationController

  def index
    @list = if params.has_key? :snapshot_id
              Snapshot.find_key(params[:snapshot_id]).deployment_roles
            elsif params.has_key? :role_id
              Role.find_key(params[:role_id]).deployment_roles
            else
              DeploymentRole.all
            end
    respond_to do |format|
      format.html { }
      format.json { render api_index DeploymentRole, @list }
    end
  end

  def show
    respond_to do |format|
      @deployment_role = DeploymentRole.find_key params[:id]
      format.html {  }
      format.json { render api_show @deployment_role }
    end
  end

  def create
    params[:role_id] = Role.find_key(params[:role]).id
    params[:snapshot_id] = Deployment.find_key(params[:deployment]).head.id
    @deployment_role = DeploymentRole.create! params.permit!(:data, :role_id, :snapshot_id)
    respond_to do |format|
      format.html { render :action=>:show }
      format.json { render api_show @deployment_role }
    end
  end

  def update
    @deployment_role = DeploymentRole.find_key(params[:id])
    params.require(:data)
    @deployment_role.update_attributes!(params.permit!(:data))
    render api_show @deployment_role
  end

  def destroy
    @deployment_role = DeploymentRole.find_key(params[:id])
    @deployment_role.destroy
    render api_delete @deployment_role
  end

end

