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
#
class DeploymentsController < ApplicationController

  def index
    @list = Deployment.all
    respond_to do |format|
      format.html { }
      format.json { render api_index Deployment, @list }
    end
  end

  def show
    @deployment = Deployment.find_key params[:id]
    respond_to do |format|
      format.html { }
      format.json { render api_show @deployment }
    end
  end

  def create
    parent_id = params[:parent] || params[:parent_id] || "system"
    @parent = Deployment.find_key(parent_id)
    return api_not_found(parent_id,Deployment) unless @parent
    params[:parent_id] = @parent.id
    @deployment = Deployment.create! params.permit(:name,:parent_id,:description)
    respond_to do |format|
      format.html { redirect_to deployment_path(@deployment.id)}
      format.json { render api_show @deployment }
    end
  end

  def destroy
    @deployment = Deployment.find_key params[:id]
    @deployment.destroy
    render api_delete @deployment
  end

  # return the committed snapshot
  def head
    deploy = Deployment.find_key params[:deployment_id]
    render_snaps(deploy.head)
  end

  # return the proposed snapshot
  def next
    deploy = Deployment.find_key params[:deployment_id]
    render_snaps(deploy.head.next)
  end

  private 

  def render_snaps(snap)
    respond_to do |format|
      format.html { redirect_to snapshot_path(snap.id) }
      format.json { render api_show snap }
    end
  end


end
