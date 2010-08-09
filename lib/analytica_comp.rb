require 'typestrict'

module Computation
  include Strict
  
  class InvalidInputException < Exception
    def initialize(comp, size, params, constraints)
      enforce!([:average_filter,
                :moving_average], comp)
      enforce_primitive!(Hash, params)
      enforce!(:string_array, constraints)

      @msg = "Unable to calculate #{comp.inspect} on DataSet size #{size} with input #{params.inspect}"
      @msg += "\nConstraints:\n"
      constraints.each do |c|
        @msg += c+"\n"
      end
    end

    def inspect
      @msg
    end
  end

  def sum
    sum = inject { |sum, x| sum + x }
    sum ? sum : 0
  end
  
  def mean
    sum.to_f / size
  end

  def linear_mean(params)
    enforce_map!({
      :bias => [:last, :first],
      :samples => :natural_number}, params)

    data = []
    
    data = self
    data.reverse! if params[:bias] == :last
    
    params[:samples] = [params[:samples], data.size].min
    
    n = params[:samples] + 1
    numerator = 0.0
    denominator = 0.0

    data.each do |sample|
      n -= 1
      n = n > 0 ? n : 0

      numerator += n*sample
      denominator += n
    end
    numerator / denominator
  end

  def exponential_mean(params)
    enforce_map!({
      :bias => [:last, :first],
      :samples => :integer}, params)

      raise "exponential_mean NYI"
  end


  def average_filter(params)
    enforce_map!({
      :decay => [:simple, :linear, :exponential],
      :offset => :natural_number, # offset from latest data point
      :samples => :natural_number}, params)

    if !(params[:offset] <= size)
      c = InvalidInputException.new(:simple_average, 
                                   size,
                                   params,
                                   [":offset <= :size"])
      raise c, c.inspect, caller
    end

    if !(params[:offset] >= params[:samples])
      c = InvalidInputException.new(:simple_average, 
                                   size,
                                   params,
                                   [":offset >= :samples"])
      raise c, c.inspect, caller
    end
    
    i = size - params[:offset]
    j = i + params[:samples]-1

    d = DataSet.new(self[i..j])

    case params[:decay]
    when :simple
      d.mean
    when :linear
      d.linear_mean(:bias => :last, :samples => d.size)
    when :exponential
      enforce_exists!(:cofficient, params)
      enforce!(:numeric, params[:cofficient])
      d.exponential_mean(:bias => :last, :samples => d.size, :coefficient => params[:cofficient])
    end
  end

  alias_method(:avg, :average_filter)

  def moving_average(params)
    enforce_map!({
      :decay => [:simple, :linear, :exponential],
      :samples => :natural_number}, params)

    if !(size >= (2*params[:samples]-1))
      c = InvalidInputException.new(:moving_average, 
                                   size,
                                   params,
                                   ["size >= (2*:samples-1)"])
      raise c, c.inspect, caller
    end

    d = DataSet.new
    (1..params[:samples]).each do |offset|
      d << average_filter(:decay => params[:decay], :cofficient => params[:cofficient], :offset => offset+params[:samples]-1, :samples => params[:samples])
    end
    d.reverse
  end

  def simple_moving_average(params)
    enforce_map!({
      :samples => :natural_number}, params)
    moving_average(:decay => :simple, :samples => params[:samples])
  end

  alias_method :sma, :simple_moving_average

  def linear_moving_average(params)
    enforce_map!({
      :samples => :natural_number}, params)
    moving_average(:decay => :linear, :samples => params[:samples])
  end

  alias_method :lma, :linear_moving_average

  def exponential_moving_average(params)
    enforce_map!({
      :samples => :integer,
      :coefficent => :float}, params)

      moving_average(:decay => :exponential, :samples => params[:samples], :cofficient => params[:cofficient])
  end

  alias_method :ema, :exponential_moving_average

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

  alias_method :dydx, :piecewise_derivative

  def savitzky_golay(n=1)
    enforce!(:natural_number, n)

    raise "savitzy_golay filter not yet implemented!"
  end
end
