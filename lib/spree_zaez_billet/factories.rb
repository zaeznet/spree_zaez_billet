FactoryGirl.define do
  factory :billet_payment_method, class: Spree::PaymentMethod::Billet do
    name 'Billet'
    created_at Date.today
  end

  factory :billet, class: Spree::Billet do
    created_at Date.today
    status 'pending'
    amount 10.0
    paid_in nil
    document_number 1
    order
    payment_method FactoryGirl.build(:billet_payment_method)
    user

    factory :billet_overdue do
      created_at (Date.today - 10.days)
    end
  end

  factory :billet_payment, class: Spree::Payment do
    amount 15.99
    association(:payment_method, factory: :billet_payment_method)
    association(:source, factory: :billet)
    order
    state 'checkout'
    response_code '1'

    factory :billet_payment_overdue do
      association(:source, factory: :billet_overdue)
    end
  end
end
