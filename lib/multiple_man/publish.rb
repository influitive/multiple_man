module MultipleMan
  def self.publish(klass, options)
    klass.include MultipleMan::Publisher
    klass.publish options
  end
end