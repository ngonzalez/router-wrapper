# Copyright © Mapotempo, 2016
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
require 'polylines'

require './api/v01/api_base'
require './api/geojson_formatter'
require './api/v01/entities/matrix_result'
require './wrappers/wrapper'
require './router_wrapper'

module Api
  module V01
    class Matrix < APIBase
      content_type :json, 'application/json; charset=UTF-8'
      content_type :geojson, 'application/vnd.geo+json; charset=UTF-8'
      content_type :xml, 'application/xml'
      formatter :geojson, GeoJsonFormatter
      # content_type :gpx, 'application/gpx+xml; charset=UTF-8'
      # formatter :gpx, GpxFormatter
      default_format :json
      version '0.1', using: :path

      resource :matrix do
        desc 'Rectangular matrix between two points set', {
          nickname: 'matrix',
          entity: MatrixResult
        }
        params {
          optional :mode, type: Symbol, desc: 'Transportation mode.'
          optional :dimension, type: Symbol, values: [:time, :distance], default: :time, desc: 'Compute fastest or shortest (default on time.)'
          optional :departure, type: Date, desc: 'Departure date time.'
          optional :arrival, type: Date, desc: 'Arrival date time.'
          optional :speed_multiplicator, type: Float, desc: 'Speed multiplicator (default: 1), not available on all transport mode.'
          optional :area, type: Array, coerce_with: ->(c) { c.split(';').collect{ |b| b.split(',').collect{ |f| Float(f) }}}, desc: 'List of latitudes and longitudes separated with commas. Areas separated with semicolons.'
          optional :speed_multiplicator_area, type: Array, coerce_with: ->(c) { c.split(';').collect{ |f| Float(f) }}, desc: 'Speed multiplicator per area, 0 avoid area. Areas separated with semicolons.'
          optional :lang, type: String, default: :en
          requires :src, type: String, desc: 'List of sources of latitudes and longitudes separated with comma, e.g. lat1,lng1,lat2,lng2...'
          optional :dst, type: String, desc: 'List of destination of latitudes and longitudes, if not present compute square matrix with sources points.'
        }
        get do
          params[:mode] ||= APIBase.services(params[:api_key])[:route_default]
          if params[:area]
            params[:area].all?{ |area| area.size % 2 == 0 } || error!('area: couples of lat/lng are needed.', 400)
            params[:area].collect{ |area| area.each_slice(2).to_a }
          end
          params[:src] = params[:src].split(',').collect{ |f| Float(f) }.each_slice(2).to_a
          params[:src][-1].size == 2 || error!('Source couples of lat/lng are needed.', 400)

          if params.key?(:dst)
            params[:dst] = params[:dst].split(',').collect{ |f| Float(f) }.each_slice(2).to_a
            params[:dst][-1].size == 2 || error!('Destination couples of lat/lng are needed.', 400)
          else
            params[:dst] =  params[:src]
          end

          results = RouterWrapper::wrapper_matrix(APIBase.services(params[:api_key]), params)
          results[:router][:version] = 'draft'
          present results, with: MatrixResult
        end
      end
    end
  end
end
