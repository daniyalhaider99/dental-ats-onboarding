class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      # citext, so "Anna@example.com" and "anna@example.com" cannot both exist.
      t.citext :email, null: false

      t.timestamps

      t.index :email, unique: true
    end
  end
end
