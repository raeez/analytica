require 'typestrict'

require File.join(File.dirname(__FILE__), 'analytica_comp')
require File.join(File.dirname(__FILE__), 'analytica_viz')

module Analytica
  VERSION = '0.0.4'

  include Strict

  class DataSet < Array
    include Computation
    include Visualization

    def initialize(datapoints)
      enforce!(:numeric_array, datapoints)

      super datapoints
    end

    def <<(object)
      enforce!(:numeric, object)
      super object
    end
  end
end
