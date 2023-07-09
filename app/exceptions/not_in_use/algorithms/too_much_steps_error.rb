module Algorithms
  class TooMuchStepsError < StandardError

    def initialize(msg="Too much steps")
      super(msg)
    end

  end
end