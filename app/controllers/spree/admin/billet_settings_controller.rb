class Spree::Admin::BilletSettingsController < Spree::Admin::BaseController

  def edit
    @config = Spree::BilletConfiguration.new
    @banks = [:banco_brasil, :itau, :caixa, :hsbc, :bradesco, :santander, :sicredi]
    @user_attr = Spree::User.new.attribute_names.sort_by { |item| item }
  end

  def update
    config = Spree::BilletConfiguration.new

    params.each do |name, value|
      next unless config.has_preference?(name)
      config[name] = value
    end

    config.registered = false unless params.include?(:registered)

    flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:billet_settings))
    redirect_to edit_admin_billet_settings_path
  end

  def clear_shipping
    Spree::BilletConfig.shipping_number = 1
    flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:billet_settings))
    redirect_to edit_admin_billet_settings_path
  end

end