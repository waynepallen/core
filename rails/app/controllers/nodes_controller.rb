# Copyright 2014, Dell
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
class NodesController < ApplicationController

  # API GET /crowbar/v2/nodes
  # UI GET /dashboard
  def index
    @list = if params.has_key? :group_id
              Group.find_key(params[:group_id]).nodes
            elsif params.has_key? :deployment_id
              Deployment.find_key(params[:deployment_id]).nodes
            elsif params.has_key? :snapshot_id
              Snapshot.find_key(params[:snapshot_id]).nodes
            else
              Node.all
            end
    respond_to do |format|
      format.html { }
      format.json { render api_index Node, @list }
    end
  end
  
  def status
    # place holder
  end

  def make_admin
    n = Node.make_admin!
    n.alive = true
    n.save!
    redirect_to :action => 'index', :status => :found
  end

  def show
    @node = Node.find_key params[:id]
    respond_to do |format|
      format.html {  } # show.html.erb
      format.json { render api_show @node }
    end
  end

  # RESTful DELETE of the node resource
  def destroy
    @node = Node.find_key(params[:id] || params[:name])
    @node.destroy
    render api_delete @node
  end

  def reboot
    node_action :reboot
  end

  def debug
    node_action :debug
  end

  def undebug
    node_action :undebug
  end

  def redeploy
    node_action :redeploy!
  end

  # RESTfule POST of the node resource
  def create
    params[:deployment_id] = Deployment.find_key(params[:deployment]).id if params.has_key? :deployment
    params[:deployment_id] ||= 1
    params.require(:name)
    params.require(:deployment_id)
    @node = Node.create!(params.permit(:name,
                                   :alias,
                                   :description,
                                   :admin,
                                   :deployment_id,
                                   :allocated,
                                   :alive,
                                   :available,
                                   :bootenv))
    # deal w/ hint shortcuts  (these are hardcoded but MUST match the imported Attrib list)
    hint = JSON.parse(params[:hint] || "{}")
    hint["network-admin"] = {"v4addr"=>params["ip"]} if params.has_key? :ip
    hint["deployer-client"] = params["mac"] if params.has_key? :mac
    unless hint.empty?
      @node.hint = hint
      @node.save!
    end

    render api_show @node
  end

  def update
    @node = Node.find_key params[:id]
    if params.has_key? :deployment
      params[:deployment_id] = Deployment.find_key(params[:deployment]).id
    end
    @node.update_attributes!(params.permit(:alias,
                                           :description,
                                           :target_role_id,
                                           :deployment_id,
                                           :allocated,
                                           :available,
                                           :alive,
                                           :bootenv))
    render api_show @node
  end

  def move
    deploy = Deployment.find_key params[:deployment_id]
    @node = Node.find_key params[:node_id]
    @node.deployment_id = deploy.id
    @node.save!
    @node.reload
    render api_show @node
  end

  #test_ methods support test functions that are not considered stable APIs
  def test_load_data

    @node = Node.find_key params[:id]
    # get the file
    file = File.join "test", "data", (params[:source] || "node_discovery") + ".json"
    raw = File.read file
    # cleanup
    mac = 6.times.map{ |i| rand(256).to_s(16) }.join(":")
    raw = raw.gsub /00:00:00:00:00:00/, mac
    # update the node
    json = JSON.load raw
    @node.discovery  = json
    @node.save!
    render api_show @node

  end

  private

  def node_action(meth)
    @node = Node.find_key(params[:id] || params[:name] || params[:node_id])
    @node.send(meth)
    render api_show @node
  end

end
