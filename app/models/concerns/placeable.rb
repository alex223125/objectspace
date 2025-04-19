module SimpleClassable
  extend ActiveSupport::Concern

  def one_of_simple_classes
    self.simple_class || self.related_simple_class
  end

end