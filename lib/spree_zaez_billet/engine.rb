module SpreeZaezBillet
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_zaez_billet'

    initializer 'spree.zaez_billet.preferences', :after => :load_config_initializers do |app|
      # require file with the preferences of the Billet
      require 'spree/billet_configuration'
      Spree::BilletConfig = Spree::BilletConfiguration.new
      #
    end

    initializer 'spree.zaez_billet.payment_methods', :after => 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::Billet
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
