Spree::Address.class_eval do

  # Return full address in same string
  #
  # @author Isabella Santos
  #
  # @return [String]
  #
  def full_address
    full = address1
    full << ", #{address2}" if address2.present?
    full << " - #{zipcode}" if zipcode.present?
    full << " - #{city}" if city.present?
    full << "/#{state.abbr}" if state.present?
    full
  end
end