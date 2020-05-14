class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :title
      t.text :text
      t.timestamps
    end

    create_table :payments do |t|
      t.belongs_to :orders
      t.bigint :payable_id
      t.string :payable_type
      t.references :order
      t.timestamps
    end
  end
end
