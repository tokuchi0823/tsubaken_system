class CreateManagerEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :manager_events do |t|
      t.string :title
      t.string :kind
      t.datetime :holded_on
      t.string :note
      t.references :manager, index: true, foreign_key: true
      
      t.timestamps
    end
  end
end