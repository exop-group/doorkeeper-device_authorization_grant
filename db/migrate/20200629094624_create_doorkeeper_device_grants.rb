# frozen_string_literal: true

class CreateDoorkeeperDeviceGrants < ActiveRecord::Migration[6.0]
  def change
    create_table :oauth_device_grants do |t|
      t.references :application, null: false
      t.string :device_code, null: false
      t.string :user_code, null: true
      t.integer :expires_in, null: false
      t.datetime :created_at, null: false
      t.datetime :last_polling_at, null: true
      t.string :scopes, null: false, default: ''
      t.references :resource_owner, null: true
    end

    add_index :oauth_device_grants, :device_code, unique: true
    add_index :oauth_device_grants, :user_code, unique: true

    add_foreign_key(
      :oauth_device_grants,
      :oauth_applications,
      column: :application_id
    )

    # Uncomment below to ensure a valid reference to the resource owner's table
    # add_foreign_key :oauth_device_grants, <model>, column: :resource_owner_id

    # Uncomment the below if you're using a polymorphic association for resource owners.
    # This allows oauth_device_grants to refer to different models (e.g., User, Admin).
    # add_column :oauth_device_grants, :resource_owner_type, :string
    # add_index :oauth_device_grants,
    #   %i[resource_owner_id resource_owner_type],
    #   name: 'index_oauth_device_grants_on_resource_owner'
  end
end
