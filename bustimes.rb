require 'net/http'
require 'json'

class Bus_Board
  def initialize(stop)
    @stop = stop
  end

  def next_5
    arrivals = fetch_arrivals
    arrivals
      .sort {|a, b| a['timeToStation'] <=> b['timeToStation']}
      .slice(0, 5)
      .each do |arrival|
        puts "#{arrival['lineName']} #{arrival['destinationName']} #{arrival['timeToStation'] / 60}"
      end
  end

  private def fetch_arrivals
    uri = URI("https://api.tfl.gov.uk/StopPoint/#{@stop}/Arrivals")
    res = Net::HTTP.get(uri)
    JSON.parse(res)
  end
end

# bus_board('490011445N')
board = Bus_Board.new('490011445N')
board.next_5
