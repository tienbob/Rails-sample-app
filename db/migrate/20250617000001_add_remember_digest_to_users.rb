class AddRememberDigestToUsers < ActiveRecord::Migration[7.1]
  def change
    # Only add the column if it doesn't already exist
    unless column_exists?(:users, :remember_digest)
      add_column :users, :remember_digest, :string
    end
  end
end
