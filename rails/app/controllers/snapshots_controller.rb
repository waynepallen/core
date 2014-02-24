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
class SnapshotsController < ApplicationController

  def index
    @list = Snapshot.order("id DESC").all
    respond_to do |format|
      format.html { }
      format.json { render api_index Snapshot, @list }
    end
  end

  def show
    @snapshot = Snapshot.find_key params[:id]
    respond_to do |format|
      format.html {
        @roles = @snapshot.deployment_roles.sort{|a,b|a.role.cohort <=> b.role.cohort}
        # alpha lists by ID
        @nodes = Node.order("name ASC").select do |n|
          (n.deployment_id == @snapshot.deployment_id) ||
          (n.node_roles.where(:snapshot_id => @snapshot.id).count > 0)
        end
      }
      format.json { render api_show @snapshot }
    end
  end

  def create
    params.require(:snapshot_id)
    @snapshot = Snapshot.create! params.permit(:snapshot_id,
                                               :name,
                                               :description)
    render api_show @snapshot
  end

  def update
    @snapshot = Snapshot.find_key params[:id]
    @snapshot.update_attributes!(params.permit(:name,:description))
    render api_show @snapshot
  end

  def destroy
    @snapshot = Snapshot.find_key params[:id]
    @snapshot.destroy
    render api_delete @snapshot
  end

  def anneal
    @snapshot = Snapshot.find_key params[:snapshot_id]
    @list = NodeRole.peers_by_state(@snapshot, NodeRole::TRANSITION).order("cohort,id")
    respond_to do |format|
      format.html {  }
      format.json { render api_index NodeRole, @list }
    end
  end

  def cohorts
    @snapshot = Snapshot.find_key params[:snapshot_id]
    respond_to do |format|
      format.html {
        @roles = @snapshot.deployment_roles.sort{|a,b|a.role.cohort <=> b.role.cohort}
        # alpha lists by ID
        @nodes = Node.order("name ASC").select do |n|
          (n.deployment_id == @snapshot.deployment_id) ||
          (n.node_roles.where(:snapshot_id => @snapshot.id).count > 0)
        end
      }
    end

  end

  def graph
    @snapshot = Snapshot.find_key params[:snapshot_id]
    respond_to do |format|
      format.html {  }
      format.json {
        graph = []
        @snapshot.node_roles.each do |nr|
          vertex = { "id"=> nr.id, "name"=> "#{nr.node.alias}: #{nr.role.name}", "data"=> {"$color"=>"#83548B"}, "$type"=>"square", "$dim"=>15, "adjacencies" =>[] }
          nr.children.each do |c|
            vertex["adjacencies"] << { "nodeTo"=> c.id, "nodeFrom"=> nr.id, "data"=> { "$color" => "#557EAA" } }
          end
          graph << vertex
        end
        render :json=>graph.to_json, :content_type=>cb_content_type(:list) 
      }
    end
  end

  def propose
    snap = Snapshot.find_key params[:snapshot_id]
    new_snap = snap.propose params[:name]
    respond_to do |format|
      format.html { redirect_to snapshot_path(new_snap.id) }
      format.json { render api_show new_snap }
    end
  end

  def commit
    snap = Snapshot.find_key params[:snapshot_id]
    snap.commit
    respond_to do |format|
      format.html { redirect_to snapshot_path(snap.id) }
      format.json { render api_show snap }
    end
  end

  def recall
    snap = Snapshot.find_key params[:snapshot_id]
    snap.recall
    respond_to do |format|
      format.html { redirect_to snapshot_path(snap.id) }
      format.json { render api_show snap }
    end
  end

end
