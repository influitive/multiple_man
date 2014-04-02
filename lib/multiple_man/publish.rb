module MultipleMan
  def self.publish(klass, options)
    klass.send(:include, MultipleMan::Publisher)
    klass.publish options
  end
end