class CreateRazorpay < ActiveRecord::Migration[6.0]
  def change
    create_table :razorpays do |t|
      t.string :razorpay
      t.string :payment_id
      t.string :o_id
      t.references :order
    end
  end
end
