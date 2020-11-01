class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.integer :status
      t.integer :before_status
      t.datetime :moved_on
      t.integer :row_order
      t.string :content
      t.integer :priority_count
      t.boolean :notification, default: false
      t.integer :default_task_id
      t.string :matter_id

      t.timestamps
    end
    add_foreign_key :tasks, :matters
    add_index  :tasks, :matter_id
  end
end
