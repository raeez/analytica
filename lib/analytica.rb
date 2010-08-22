require 'typestrict'

require File.join(File.dirname(__FILE__), 'computation')
require File.join(File.dirname(__FILE__), 'visualization')

module Analytica
  VERSION = '0.0.19'

  include Strict

  dataset_array_handler = proc do |data, context|
    enforce_primitive!(Array, data, context)
    data.each {|item| enforce_primitive!(DataSet, item, context)}
  end

  register_supertype(:dataset_array, dataset_array_handler)

  string_array_2d_handler = proc do |data, context|
    enforce_primitive!(Array, data, context)
    data.each {|item| enforce!(:string_array, item, context)}
  end

  register_supertype(:string_array_2d, string_array_2d_handler)

  class DataSet < Array
    include Analytica::Computation
    include Analytica::Visualization::Representation
    include Analytica::Visualization::DataSet
  
    attr_accessor :labels

    def initialize(datapoints=[])
      enforce!(:numeric_array, datapoints)

      @labels = {}
      @labels_set = false

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

  class DataSystem < Array
    include Analytica::Visualization::Representation
    include Analytica::Visualization::DataSystem

    attr_accessor :labels

    def initialize(datasets=[])
      enforce!(:dataset_array, datasets)

      @labels = {}
      @labels_set = false

      super datasets
    end

    def <<(object)
      enforce_primitive!(DataSet, object)

      super object
    end

    def concat(other)
      enforce!(:dataset_array, other)

      super datasets
    end

    def +(other)
      enforce!(:dataset_array, other)

      super other
    end
  end
end
