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
      sum = inject { |sum, x| sum + x }
      sum ? sum : 0
    end
    
    def mean
      sum.to_f / size
    end

    def moving_average(params)
      enforce_map!({
        :decay => [:exponential, :linear],
        :decay_coefficent => :float}, params)

      raise "moving_average not yet implemented!"
    end
    
    def piecewise_derivative(n=1)
      enforce!(:natural_number, n)

      d = self
      n.times do
        d = d.inject([]) do |result, item|
          if result.size == 0
            result << item
          else
            d_y = (item - result.last).to_f
            d_x = 1.0 #account for d_x eventually
            deriv = d_y/d_x
            result.pop
            result << deriv
            result << item unless (result.size) == (d.size-1)
            result
          end
        end
      end
      DataSet.new(d)
    end

    def savitzky_golay(n=1)
      enforce!(:natural_number, n)

      raise "savitzy_golay filter not yet implemented!"
    end

    def datamax
      (max > 0) ? max : 1
    end

    def to_linegraph(params)
      enforce_map!({
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
      enforce_map!({
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
