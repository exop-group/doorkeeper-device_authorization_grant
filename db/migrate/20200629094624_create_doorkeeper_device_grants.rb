# frozen_string_literal: true

class CreateDoorkeeperDeviceGrants < ActiveRecord::Migration[6.0]
  def change
    create_table :oauth_device_grants do |t|
      t.references :resource_owner, null: true
      t.references :application, null: false
      t.string :device_code, null: false
      t.string :user_code, null: true
      t.integer :expires_in, null: false
      t.datetime :created_at, null: false
      t.datetime :last_polling_at, null: true
      t.string :scopes, null: false, default: ''
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
  end
end
