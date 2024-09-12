require 'net/http'
require 'json'

class Bus_Board
  def next_5
    @stops.each do |stop|
      arrivals = fetch_arrivals(stop)
      puts arrivals[0]['stationName']
      arrivals
        .sort {|a, b| a['timeToStation'] <=> b['timeToStation']}
        .slice(0, 5)
        .each do |arrival|
          puts "#{arrival['lineName']} #{arrival['destinationName']} #{arrival['timeToStation'] / 60}"
        end
      puts
    end
  end

  private def fetch_arrivals(stop)
    uri = URI("https://api.tfl.gov.uk/StopPoint/#{stop}/Arrivals")
    res = Net::HTTP.get(uri)
    JSON.parse(res)
  end
end

class Bus_Board_Stop < Bus_Board
  def initialize(stop)
    @stops = [stop]
  end
end

class Bus_Board_Postcode < Bus_Board
  def initialize(postcode)
    uri = URI("https://api.postcodes.io/postcodes/#{postcode.gsub(' ', '%20')}")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)

    lat = data['result']['latitude']
    lon = data['result']['longitude']

    uri = URI("https://api.tfl.gov.uk/StopPoint/?lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram")
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)

    @stops = data['stopPoints'].map {|stop| stop['id']}
  end
end

# 490008825N

# board = Bus_Board_Stop.new(gets.chomp)
# board.next_5

board = Bus_Board_Postcode.new(gets.chomp)
board.next_5
