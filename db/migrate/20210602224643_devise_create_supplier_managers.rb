class DeviseCreateSupplierManagers < ActiveRecord::Migration[5.2]
  def change
    create_table :supplier_managers do |t|

      t.string :auth,               null: false, default: "supplier_manager"
      t.string :name,               null: false
      t.string :kana
      t.string :phone
      t.string :email
      t.date :resigned_on
      t.boolean :avaliable,         null: false, default: true
      t.references :supplier,       foreign_key: true

      ## Database authenticatable
      t.string :login_id,           null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      ## Rememberable
      t.datetime :remember_created_at
      t.timestamps null: false
    end
    add_index :supplier_managers, :login_id,     unique: true
  end
end
