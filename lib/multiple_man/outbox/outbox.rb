module MultipleMan
  module Outbox
    module_function

    def count
      MessageAdapter.adapter.count
    end
  end
end
