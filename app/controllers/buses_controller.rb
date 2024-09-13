require 'net/http'
require 'json'

class BusesController < ApplicationController
  def index
  end

  def stop
    stop = params[:stop]
    @arrivals = fetch_arrivals([stop])
    render :arrivals
  end

  def postcode
    postcode = params[:postcode]
    lat, lon = fetch_postcode_coordinates(postcode)
    stops = fetch_nearest_stops(lat, lon)
    @arrivals = fetch_arrivals(stops)
    render :arrivals
  end

  private

  def fetch_arrivals(stops)
    arrivals = []

    stops.each do |stop|
      uri = URI("https://api.tfl.gov.uk/StopPoint/#{stop}/Arrivals")
      res = Net::HTTP.get(uri)
      buses = JSON.parse(res)
      buses
        .sort_by! { |x| x['timeToStation'].to_i }
        .slice(0, 5)
      arrivals.push(buses)
    end

    arrivals
  end

  def fetch_nearest_stops(lat, lon)
    uri = URI("https://api.tfl.gov.uk/StopPoint/?lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)
    data['stopPoints'].map { |stop| stop['id'] }
  end

  def fetch_postcode_coordinates(postcode)
    uri = URI("https://api.postcodes.io/postcodes/#{postcode.gsub(' ', '%20')}")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)
    [data['result']['latitude'], data['result']['longitude']]
  end
end
