require 'typestrict'

require File.join(File.dirname(__FILE__), 'computation')
require File.join(File.dirname(__FILE__), 'visualization')

module Analytica
  VERSION = '0.0.7'

  include Strict

  class DataSet < Array
    include Analytica::Computation
    include Analytica::Visualization

    def initialize(datapoints=[])
      enforce!(:numeric_array, datapoints)

      super datapoints
    end

    def <<(object)
      enforce!(:numeric, object)
      super object
    end

    def concat(other)
      enforce!(:numeric_array, other)
      super other
    end

    def +(other)
      enforce!(:numeric_array, other)
      super other
    end
  end
end
