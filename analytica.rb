require 'gchart'

basereq 'strict/strict'

module Analytica
  include Strict

  class DataSet < Array
    def initialize(datapoints)
      enforce!(:numeric_array, datapoints)

      super datapoints
    end

    def set_labels(labels)
      enforce!(:string_array, labels)

      @labels = labels
    end

    def sum
      inject( nil ) { |sum, x| sum ? sum + x : x }
    end
    
    def mean
      sum.to_f / size
    end

    def moving_average(params)
      validate_map!({
        :decay => [:exponential, :linear],
        :decay_coefficent => :float}, params)

    end
    
    def piecewise_derivative(n=1)
      enforce!(:natural_number, n)

      d = self
      n.times do
        d = 
      end
      d
    end

    def datamax
      (max > 0) ? max : 1
    end

    def to_linegraph(params)
      validate_map!({
        :width => :natural_number,
        :height => :natural_number,
        :background_color => :hex_color,
        :color => :hex_color}, params)

      GChart.line do |g|
        g.data = self
        g.extras = {
          'chm' => 'N*cUSD0*,000000,0,-1,11', 
          'chbh' => '18,38',
          'chds' => "0,#{datamax}"
        }
        g.size = "#{(params[:width]).to_i}x#{(params[:height]).to_i}"
        g.entire_background = params[:background_color].to_s
        g.colors = params[:color].to_s
        g.axis(:bottom) {|a| a.labels = @labels}
      end
    end

    def to_bargraph(params)
      validate_map!({
        :width => :natural_number,
        :height => :natural_number,
        :orientation => [:vertical, :horizontal],
        :background_color => :hex_color,
        :color => :hex_color}, params)

      GChart.bar do |g|
        g.data = self
        g.extras = {
          'chm' => 'N*cUSD0*,000000,0,-1,11', 
          'chbh' => '18,38',
          'chds' => "0,#{datamax}"
        }
        g.size = "#{(params[:width]).to_i}x#{(params[:height]).to_i}"
        g.entire_background = params[:background_color].to_s
        g.colors = params[:color].to_s
        g.orientation = params[:orientation]
        g.axis(:bottom) {|a| a.labels = @labels}
      end
    end
  end
end
