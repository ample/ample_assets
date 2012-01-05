class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.integer :file_id
      t.timestamps
    end
  end
end
