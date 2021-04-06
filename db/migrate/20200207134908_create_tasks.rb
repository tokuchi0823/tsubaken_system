class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title,         null: false, default: ""
      t.integer :position
      t.integer :status
      t.integer :before_status
      t.datetime :moved_on
      t.integer :sort_order
      t.string :content
      t.integer :default_task_id
      t.boolean :alert, default: false
      t.boolean :auto_set, default: false
      t.string :estimate_matter_id
      t.string :matter_id
      t.references :member_code      
      t.string :member_name # 担当者が削除された時のカラム

      t.timestamps
    end
    add_index  :tasks, :matter_id
    add_index  :tasks, :estimate_matter_id
    add_foreign_key :tasks, :matters
    add_foreign_key :tasks, :estimate_matters
  end
end
