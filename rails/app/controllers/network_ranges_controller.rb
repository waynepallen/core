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
class NetworkRangesController < ::ApplicationController
  respond_to :json

  def index
    @list = if params.has_key? :network_id or params.has_key? :network
      network =  Network.find_key params[:network_id] || params[:network]
      network.network_ranges
    else
      NetworkRange.all
    end
    respond_to do |format|
      format.html { }
      format.json { render api_index :network_range, @list }
    end
  end

  def show
    network =  Network.find_key params[:network_id]
    @range = network.network_ranges.find_key(params[:id]) rescue nil
    respond_to do |format|
      format.html { 
                    @list = [@range]
                    render :action=>:index 
                  } 
      format.json { render api_show :network_range, NetworkRange, nil, nil, @range }
    end
  end

  def create
    params[:network_id] = Network.find_key(params[:network]).id if params.has_key? :network
    @range = NetworkRange.new
    @range.first = params[:new_first]
    @range.last = params[:new_last]
    @range.name = params[:name]
    @range.network_id = params[:network_id]
    @range.save!
    respond_to do |format|
      format.json { render api_show :network_range, NetworkRange, @range.id.to_s, nil, @range }
    end

  end

  def update
    params[:network_id] = Network.find_key(params[:network]).id if params.has_key? :network
    if params.has_key? :id
      nr = NetworkRange.find_key params[:id]
    else
      nr = NetworkRange.where(:name=>params[:name], :network_id=>params[:network_id]).first
    end
    respond_to do |format|
      format.json { render api_update :network_range, NetworkRange, nil, nr }
    end
  end

end
