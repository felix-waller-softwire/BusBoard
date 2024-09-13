require 'net/http'
require 'json'

class BusesController < ApplicationController
  def index
    stop = params[:stop]
    uri = URI("https://api.tfl.gov.uk/StopPoint/#{stop}/Arrivals")
    res = Net::HTTP.get(uri)
    arrivals = JSON.parse(res)
    arrivals
      .sort_by! { |x| x['timeToStation'].to_i }
      .slice(0, 5)
    @buses = arrivals
  end

  def postcode
    postcode = params[:postcode]

    uri = URI("https://api.postcodes.io/postcodes/#{postcode.gsub(' ', '%20')}")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)

    lat = data['result']['latitude']
    lon = data['result']['longitude']

    uri = URI("https://api.tfl.gov.uk/StopPoint/?lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)

    stops = data['stopPoints'].map {|stop| stop['id']}

    @stops = []

    stops.each do |stop|
      uri = URI("https://api.tfl.gov.uk/StopPoint/#{stop}/Arrivals")
      res = Net::HTTP.get(uri)
      arrivals = JSON.parse(res)
      arrivals
        .sort_by! { |x| x['timeToStation'].to_i }
        .slice(0, 5)
      @stops.push(arrivals)
    end
  end
end
