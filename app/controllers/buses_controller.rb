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

    status, lat, lon = fetch_postcode_coordinates(postcode)
    return render :index, locals: { err: :invalid_postcode } if status != 200

    stops = fetch_nearest_stops(lat, lon)
    return render :index, locals: { err: :postcode_has_no_stops } if stops.nil? || stops.empty?

    @arrivals = fetch_arrivals(stops)
    render :arrivals
  end

  private

  def fetch_arrivals(stops)
    stops.map do |stop|
      uri = URI("https://api.tfl.gov.uk/StopPoint/#{stop}/Arrivals")
      res = Net::HTTP.get(uri)
      data = JSON.parse(res)

      next if !data.kind_of?(Array)

      data.sort_by { |x| x['timeToStation'].to_i }
          .first(5)
    end
  end

  def fetch_nearest_stops(lat, lon)
    uri = URI("https://api.tfl.gov.uk/StopPoint/?lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)
    data['stopPoints']&.map { |stop| stop['id'] }
  end

  def fetch_postcode_coordinates(postcode)
    uri = URI("https://api.postcodes.io/postcodes/#{postcode.gsub(' ', '%20')}")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)
    [data['status'], data&.dig('result', 'latitude'), data&.dig('result', 'longitude')]
  end
end
