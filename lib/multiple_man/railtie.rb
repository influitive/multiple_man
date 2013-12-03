require 'multiple_man'
require 'rails'

module MultipleMan
  class Railtie < Rails::Railtie
    railtie_name :multiple_man

    rake_tasks do
      load "multiple_man/tasks/worker.rake"
    end
  end
end