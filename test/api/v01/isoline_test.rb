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
require './test/test_helper'

require './api/root'

class Api::V01::IsolineTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Api::Root
  end

  def test_isoline
    get '/0.1/isoline', {api_key: 'demo', loc: '43.2804,5.3806', size: 33, departure: Time.now}
    assert last_response.ok?, last_response.body
  end

  def test_isoline_none_loc
    get '/0.1/isoline', {api_key: 'demo'}
    assert !last_response.ok?, last_response.body
  end

  def test_isoline_outside_area
    get '/0.1/isoline', {api_key: 'demo', loc: '1,1', size: 1, departure: Time.now}
    assert_equal 417, last_response.status, 'Bad response: ' + last_response.body
  end
end
