class EnablePostgresExtensions < ActiveRecord::Migration[8.1]
  def change
    # gen_random_uuid() for UUID primary keys.
    enable_extension "pgcrypto"

    # Case-insensitive email, so uniqueness is enforced by the database rather
    # than by remembering to downcase in every code path that writes a user.
    enable_extension "citext"
  end
end
