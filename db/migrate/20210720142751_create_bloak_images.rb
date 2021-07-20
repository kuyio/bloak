class CreateBloakImages < ActiveRecord::Migration[6.1]
  def change
    create_table :bloak_images do |t|
      t.string :name
      t.string :alt

      t.timestamps
    end

    add_index :bloak_images, :name, unique: true
  end
end
