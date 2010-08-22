require 'googlecharts'
require 'typestrict'

module Analytica
  module Visualization

    module Representation
      def set_labels(params={})
        enforce_map_defaults!({
          :data => [],
          :type => :x_axis,
          :prefix => ' ',
          :postfix => ' ',
          :decimal => 0,
          :color => '000000',
          :size => 10}, params)

        enforce_primitive!(Array, params[:data])

        enforce_map!({
          :type => [:axis, :x_axis, :y_axis, :data],
          :prefix => :string,
          :decimal => :integer,
          :color => :hex_color,
          :size => :natural_number}, params)

        @labels_set = true

        @labels = {} if @labels.nil?
        @labels[params[:type]] = {}

        @labels[params[:type]][:prefix] = params[:prefix] == ' ' ? '' : params[:prefix]
        @labels[params[:type]][:postfix] = params[:postfix] == ' ' ? '' : params[:postfix]
        @labels[params[:type]][:decimal]  = params[:decimal]
        @labels[params[:type]][:color] = params[:color]
        @labels[params[:type]][:size] = params[:size]
        @labels[params[:type]][:data] = params[:data]
      end

      def set_title(params)
        enforce_map!({
          :text => :string,
          :size => :natural_number,
          :color => :hex_color}, params)

        @title = params
        @title_set = true
      end

      def bar_settings(bar_settings)
        enforce_map_optional!({
          :width => :natural_number,
          :spacing => :natural_number,
          :group_spacing => :natural_number}, bar_settings)
        bar_settings
      end

      def generate_title
        options = {}
        if @title_set
          options.merge!({:title => @title[:text], :title_size => @title[:size], :title_color => @title[:color]})
        end
        options
      end

      def generate_labels
        options = {}
        if @labels_set
          if @labels[:data]
            @labels[:data][:data].each {|element| data_string += ",#{element.to_f}"}
            data_labels = {
              :custom => "chm=N#{@labels[:data][:prefix]}*f#{@labels[:data][:decimal]}*#{@labels[:data][:postfix]},#{@labels[:data][:color]},0,-1,#{@labels[:data][:size]}&amp;chds=0,#{datamax}"
            }
            options.merge!(data_labels)
          end

          if @labels[:axis]
            axis_labels = {
              :axis_with_labels => ['x', 'y'],
              :axis_labels => [@labels[:axis][:data], ["#{0}", "#{(datamax*0.5).to_i}",  "#{datamax.to_i}"]]
            }
            options.merge!(axis_labels)
          elsif @labels[:x_axis]
            x_axis_label = {
              :axis_with_labels => 'x',
              :axis_labels => @labels[:x_axis][:data].size == 0 ? self.map{|n|"#{n}"} : @labels[:x_axis][:data]
            }
            options.merge!(x_axis_label)
          elsif @labels[:y_axis]
            y_axis_label = {
              :axis_with_labels => 'y',
              :axis_labels => @labels[:y_axis][:data].size == 0 ? ["#{0}", "#{(datamax*0.5).to_i}",  "#{datamax.to_i}"] : @labels[:y_axis][:data]
            }
            options.merge!(y_axis_label)
          end
        end
        options
      end

      def common_options
        options = {}
        options.merge!(generate_labels)
        options.merge!(generate_title)
        options
      end
    end

    module DataSet
      include Strict

      def datamax
      (max > 0) ? (1.1*max) : 1
      end

      def to_linegraph(params={})
        enforce_map_defaults!({
          :title => {:text => ' ', :color => "000000", :size => 12},
          :color => 'ffffff',
          :background_color => '000000',
          :width => 600,
          :height => 280,
          :format => :image_tag,
          :bar_settings => {}}, params)

        enforce_map!({
          :title => :hash_map,
          :width => :natural_number,
          :height => :natural_number,
          :background_color => :hex_color,
          :format => [:url, :image_tag],
          :color => :hex_color}, params)


        options = {}

        options.merge!({:format => 'image_tag'}) if params[:format] == :image_tag

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}"
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
          :title => {:text => ' ', :color => "000000", :size => 12},
          :color => '0000ff',
          :background_color => 'ffffff',
          :width => 600,
          :height => 180,
          :format => :image_tag,
          :bar_settings => {}}, params)

        enforce_map!({
          :title => :hash_map,
          :width => :natural_number,
          :height => :natural_number,
          :background_color => :hex_color,
          :format => [:url, :image_tag],
          :color => :hex_color}, params)

        params[:title] = '' unless params.has_key? :title
        params[:title_size] = 12 unless params.has_key? :title_size
        params[:title_color] = '000000' unless params.has_key? :title_color


        options = {}

        options.merge!({:format => 'image_tag'}) if params[:format] == :image_tag

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}"
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
          :title => {:text => ' ', :color => "000000", :size => 12},
          :orientation => :vertical,
          :color => '00bb00',
          :background_color => 'ffffff',
          :stacked => false,
          :width => 600,
          :height => 280,
          :stacked => false,
          :format => :image_tag,
          :bar_settings => {}}, params)

        enforce_map!({
          :title => :hash_map,
          :width => :natural_number,
          :height => :natural_number,
          :orientation => [:vertical, :horizontal],
          :stacked => :boolean,
          :background_color => :hex_color,
          :color => :hex_color,
          :format => [:url, :image_tag],
          :bar_settings => :hash_map}, params)

        options = {}

        options.merge!({:format => 'image_tag'}) if params[:format] == :image_tag

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}",
          :orientation => params[:orientation].to_s,
          :stacked => params[:stacked],
          :bar_width_and_spacing => bar_settings(params[:bar_settings])
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

      def datamax
        (self.map{|dset| dset.datamax}).max
      end

      def to_linegraph(params={})
        enforce_map_defaults!({
          :title => {:text => ' ', :color => "000000", :size => 12},
          :color => 'ffffff',
          :width => 600,
          :height => 280,
          :format => :image_tag,
          :background_color => '000000'}, params)

        enforce_map!({
          :title => :hash_map,
          :width => :natural_number,
          :height => :natural_number,
          :background_color => :hex_color,
          :format => [:url, :image_tag],
          :color => :hex_color}, params)

        options = {}

        options.merge!({:format => 'image_tag'}) if params[:format] == :image_tag

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}"
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
          :title => {:text => ' ', :color => "000000", :size => 12},
          :orientation => :vertical,
          :color => 'ffffff',
          :background_color => '000000',
          :width => 600,
          :height => 280,
          :stacked => false,
          :format => :image_tag,
          :bar_settings => {}}, params)

        enforce_map!({
          :title => :hash_map,
          :width => :natural_number,
          :height => :natural_number,
          :orientation => [:vertical, :horizontal],
          :stacked => :boolean,
          :background_color => :hex_color,
          :colors => :hex_color_array,
          :format => [:url, :image_tag],
          :bar_settings => :hash_map}, params)

        options = {}

        options.merge!({:format => 'image_tag'}) if params[:format] == :image_tag

        base = {
          :data => self,
          :max_value => datamax,
          :size => "#{params[:width]}x#{params[:height]}",
          :orientation => params[:orientation].to_s,
          :stacked => params[:stacked],
          :bar_width_and_spacing => bar_settings(params[:bar_settings])
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
