class CreateConstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :constructions do |t|
      t.string :name,            null: false
      t.boolean :default,        default: false
      t.string :note
      t.string :unit
      t.integer :price
      t.integer :amount
      t.string :total
      t.references :category,    foreign_key: true

      t.timestamps
    end
  end
end
