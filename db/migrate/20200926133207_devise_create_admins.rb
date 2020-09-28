# frozen_string_literal: true

class DeviseCreateAdmins < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.string :name,               null: false, default: ""

      ## Database authenticatable
      t.string :employee_id,        null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.string :name

      t.timestamps null: false
    end

    add_index :admins, :employee_id,          unique: true
    add_index :admins, :reset_password_token, unique: true
  end
end