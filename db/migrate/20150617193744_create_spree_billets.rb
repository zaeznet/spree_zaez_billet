class CreateSpreeBillets < ActiveRecord::Migration
  def change
    create_table :spree_billets do |t|
      t.string :status
      t.decimal :amount
      t.date :paid_in
      t.integer :document_number
      t.references :order
      t.references :payment_method
      t.references :user
      t.timestamps null: false
    end
  end
end
