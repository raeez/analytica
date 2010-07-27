require '../strict/strict'

require 'analytica_comp'
require 'analytica_viz'


module Analytica
  include Strict

  class DataSet < Array
    include Computation
    include Visualization

    def initialize(datapoints)
      enforce!(:numeric_array, datapoints)

      super datapoints
    end
  end
end
