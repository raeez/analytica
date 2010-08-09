require 'typestrict'
require 'gchart'

class GChart::Base
  def to_html
    "<img src=\"#{self.to_url}\" />"
  end
end

module Visualization
  include Strict

  def set_labels(labels)
  enforce!(:string_array, labels)

    @labels = labels
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
        'chbh' => '45,30',
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
