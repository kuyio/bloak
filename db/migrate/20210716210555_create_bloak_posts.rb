class CreateBloakPosts < ActiveRecord::Migration[6.1]
  def change
    create_table :bloak_posts do |t|
      t.string :slug
      t.string :title
      t.string :topic
      t.string :summary
      t.text   :content
      t.string :author_name
      t.string :author_email
      t.boolean :published, default: false
      t.boolean :featured, default: false
      t.integer :reading_time, default: 1

      t.datetime :published_at
      t.timestamps
    end

    add_index :bloak_posts, :slug, unique: true
  end
end
