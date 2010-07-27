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
end
