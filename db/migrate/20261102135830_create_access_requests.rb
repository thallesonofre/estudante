# frozen_string_literal: true

class CreateAccessRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :access_requests do |t|
      t.string :institution_name, null: false
      t.string :institution_type, null: false
      t.string :contact_name, null: false
      t.string :email, null: false
      t.string :phone
      t.integer :requested_role, null: false, default: 2
      t.integer :status, null: false, default: 0
      t.text :message
      t.string :generated_password
      t.datetime :reviewed_at
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.references :provisioned_user, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :access_requests, :email
    add_index :access_requests, :status
  end
end
