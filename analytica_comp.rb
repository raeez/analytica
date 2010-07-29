require '../strict/strict'

module Computation
  include Strict

  def sum
    sum = inject { |sum, x| sum + x }
    sum ? sum : 0
  end
  
  def mean
    sum.to_f / size
  end
 
  def lma(params)
    linear_moving_average(params)
  end

  def linear_moving_average(params)
    enforce_map!({
      :bias => [:last, :first],
      :samples => :integer}, params)

    data = []
    case params[:bias]
    when :last
      data = self.reverse
    when :first
      data = self
    else
      raise "Bias not legally set!"
    end
    
    raise "too few samples available to calculate lma at given :samples input" if params[:samples] > size
    
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

  def ema(params)
    exponential_moving_average(params)
  end

  def exponential_moving_average(params)
    enforce_map!({
      :decay => [:exponential, :linear],
      :decay_bias => [:latest, :oldest],
      :decay_coefficent => :float}, params)

    if params[:decay_bias] == :latest
      data = self
    else
      data = self.reverse
    end
    0.0
  end

  def dydx(n=1)
    piecewise_derivative(n)
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
end
