class CreateAmpleAssetsFiles < ActiveRecord::Migration
  def change
    create_table :ample_assets_files do |t|
      t.string   :keywords
      t.string   :alt_text
      t.string   :attachment_uid
      t.string   :attachment_mime_type
      t.string   :attachment_ext
      t.string   :attachment_name
      t.integer  :attachment_width
      t.integer  :attachment_height
      t.string   :attachment_gravity
      t.timestamps
    end
  end
end
