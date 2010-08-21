require 'googlecharts'
require 'typestrict'

module Analytica
  module Visualization
    module Common
      def set_title(params)
        enforce_map!({
          :title => :string,
          :title_size => :natural_number,
          :title_color => :hex_color}, params)

        @title = params
        @title_set = true
      end

      def common_options
        options = {}

        if @labels_set
          label = {
            :axis_with_labels => ['x', 'y'],
            :axis_labels => [@labels, ["#{0}", "#{(datamax*0.25).to_i}", "#{(datamax*0.5).to_i}", "#{(datamax*0.75).to_i}", "#{datamax.to_i}"]]
          }

          options.merge!(label)
        end

        if @title_set
          options.merge!(@title)
        end

        options
      end
    end

    module DataSet
      include Strict

      def set_labels(labels)
        enforce!(:string_array, labels)

        @labels = labels
        @labels_set = true
      end

      def bar_settings(bar_settings)
        enforce_map_optional!({
          :width => :natural_number,
          :spacing => :natural_number,
          :group_spacing => :natural_number}, bar_settings)
        bar_settings
      end

      def datamax
      (max > 0) ? (1.25*max) : 1
      end

      def to_linegraph(params={})
        enforce_map_defaults!({
          :title => ' ',
          :title_size => 12,
          :title_color => '000000',
          :color => 'ffffff',
          :background_color => '000000',
          :width => 600,
          :height => 280,
          :bar_settings => {}}, params)

        enforce_map!({
          :title => :string,
          :title_size => :natural_number,
          :title_color => :hex_color,
          :width => :natural_number,
          :height => :natural_number,
          :background_color => :hex_color,
          :color => :hex_color}, params)


        options = {}

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}",
          :format => 'image_tag'
        }

        options.merge!(base)

        color = {
          :line_colors => params[:color],
          :background => params[:background_color],
          :chart_background => params[:background_color]
        }

        options.merge!(color)

        options.merge!(common_options)

        Gchart.line(options)
      end

      def to_sparkline(params={})
        enforce_map_defaults!({
          :title => ' ',
          :title_size => 12,
          :title_color => '000000',
          :color => '0000ff',
          :background_color => 'ffffff',
          :width => 600,
          :height => 280,
          :bar_settings => {}}, params)

        enforce_map!({
          :title => :string,
          :title_size => :natural_number,
          :title_color => :hex_color,
          :width => :natural_number,
          :height => :natural_number,
          :background_color => :hex_color,
          :color => :hex_color}, params)

        params[:title] = '' unless params.has_key? :title
        params[:title_size] = 12 unless params.has_key? :title_size
        params[:title_color] = '000000' unless params.has_key? :title_color


        options = {}

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}",
          :format => 'image_tag'
        }

        options.merge!(base)

        color = {
          :line_colors => params[:color],
          :background => params[:background_color],
          :chart_background => params[:background_color]
        }

        options.merge!(color)

        options.merge!(common_options)

        Gchart.sparkline(options)
      end


      def to_bargraph(params={})
        enforce_map_defaults!({
          :title => ' ',
          :title_size => 12,
          :title_color => '000000',
          :orientation => :vertical,
          :color => 'ffffff',
          :background_color => '000000',
          :stacked => false,
          :width => 600,
          :height => 280,
          :bar_settings => {}}, params)

        enforce_map!({
          :title => :string,
          :title_size => :natural_number,
          :title_color => :hex_color,
          :width => :natural_number,
          :height => :natural_number,
          :orientation => [:vertical, :horizontal],
          :stacked => :boolean,
          :background_color => :hex_color,
          :color => :hex_color,
          :bar_settings => :hash_map}, params)

        options = {}

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}",
          :orientation => params[:orientation].to_s,
          :stacked => params[:stacked],
          :bar_width_and_spacing => bar_settings(params[:bar_settings]),
          :format => 'image_tag'
        }

        options.merge!(base)

        color = {
          :bar_colors => params[:color],
          :background => params[:background_color],
          :chart_background => params[:background_color]
        }

        options.merge!(color)

        options.merge!(common_options)
        
        return Gchart.bar(options)
      end
    end

    module DataSystem

      def bar_settings(bar_settings)
        enforce_map_optional!({
          :width => :natural_number,
          :spacing => :natural_number,
          :group_spacing => :natural_number}, bar_settings)
        bar_settings
      end

      def set_labels(labels)
        enforce!(:string_array, labels)

        @labels = labels
        @labels_set = true
      end

      def datamax
        (self.map{|dset| dset.datamax}).max
      end

      def to_linegraph(params={})
        enforce_map_defaults!({
          :title => ' ',
          :title_size => 12,
          :title_color => '000000',
          :color => 'ffffff',
          :width => 600,
          :height => 280,
          :background_color => '000000'}, params)


        enforce_map!({
          :title => :string,
          :title_size => :natural_number,
          :title_color => :hex_color,
          :width => :natural_number,
          :height => :natural_number,
          :background_color => :hex_color,
          :color => :hex_color}, params)

        options = {}

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}",
          :format => 'image_tag'
        }

        options.merge!(base)

        color = {
          :line_colors => params[:colors],
          :background => params[:background_color],
          :chart_background => params[:background_color]
        }

        options.merge!(color)

        options.merge!(common_options)

        Gchart.line(options)
      end

      def to_bargraph(params={})
        enforce_map_defaults!({
          :title => ' ',
          :title_size => 12,
          :title_color => '000000',
          :orientation => :vertical,
          :color => 'ffffff',
          :background_color => '000000',
          :width => 600,
          :height => 280,
          :bar_settings => {}}, params)

        enforce_map!({
          :title => :string,
          :title_size => :natural_number,
          :title_color => :hex_color,
          :width => :natural_number,
          :height => :natural_number,
          :orientation => [:vertical, :horizontal],
          :stacked => :boolean,
          :background_color => :hex_color,
          :colors => :hex_color_array,
          :bar_settings => :hash_map}, params)

        options = {}

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}",
          :orientation => params[:orientation].to_s,
          :stacked => params[:stacked],
          :bar_width_and_spacing => bar_settings(params[:bar_settings]),
          :format => 'image_tag'
        }

        options.merge!(base)

        color = {
          :bar_colors => params[:colors],
          :background => params[:background_color],
          :chart_background => params[:background_color]
        }

        options.merge!(color)

        options.merge!(common_options)

        return Gchart.bar(options)
      end
    end
  end
end
