class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :title
      t.string :body_html
      t.string :body_text
      t.references :user, index:true
      t.timestamps
    end
  end
end