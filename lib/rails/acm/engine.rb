module Rails::Acm
  class Engine < ::Rails::Engine
    rake_tasks do
      load File.join(__dir__, "../../tasks/certificates.rake")
    end
  end
end
