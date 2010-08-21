require "test/unit"
require "analytica"

class TestAnalytica < Test::Unit::TestCase
  def test_sanity
    a = Analytica::DataSet.new([3, 8, 3, 9, 2, 7])
    puts a.to_bargraph(:width => 500, :height => 230, :color => 'ffffff', :background_color => '000000', :orientation => :vertical).gsub("\"", "'").inspect
  end
end
