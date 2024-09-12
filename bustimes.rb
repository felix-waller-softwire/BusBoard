require 'net/http'
require 'json'

def bus_board(stop)
  arrivals = fetch_arrivals(stop)
  arrivals
    .sort {|a, b| a['timeToStation'] <=> b['timeToStation']}
    .slice(0, 5)
    .each do |arrival|
      puts "#{arrival['lineName']} #{arrival['destinationName']} #{arrival['timeToStation'] / 60}"
    end
end

def fetch_arrivals(stop)
  uri = URI("https://api.tfl.gov.uk/StopPoint/#{stop}/Arrivals")
  res = Net::HTTP.get(uri)
  JSON.parse(res)
end

bus_board('490011445N')
