module SimpleClassable
  extend ActiveSupport::Concern

  def closest_simple_classes
    self.simple_class || self.related_simple_class
  end

end