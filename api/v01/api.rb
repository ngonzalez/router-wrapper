# Copyright © Mapotempo, 2015-2016
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
require 'grape'
require 'grape-swagger'

require './api/v01/route'
require './api/v01/matrix'
require './api/v01/isoline'
require './api/v01/capability'

module Api
  module V01
    class Api < Grape::API
      before do
        if !::RouterWrapper::config[:api_keys].include?(params[:api_key])
          error!('401 Unauthorized', 401)
        end
      end

      rescue_from :all do |error|
        case error
        when Grape::Exceptions::ValidationErrors
          error!(error.message, 400)
        when RouterWrapper::RouterWrapperError
          error!(error.message, 417)
        when Wrappers::UnreachablePointError
          error!(error.message, 204)
        else
          message = {error: error.class.name, detail: error.message}
          if ['development', 'production'].include?(ENV['APP_ENV'])
            message[:trace] = error.backtrace
            STDERR.puts error.message
            STDERR.puts error.backtrace
          end
          error!(message, 500)
        end
      end

      mount Route
      mount Matrix
      mount Isoline
      mount Capability

      private

      def services
        ::RouterWrapper::config[:api_keys][params[:api_key]]
      end
    end
  end
end
