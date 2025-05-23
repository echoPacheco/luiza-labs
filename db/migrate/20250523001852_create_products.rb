class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.integer :product_id
      t.decimal :value
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
