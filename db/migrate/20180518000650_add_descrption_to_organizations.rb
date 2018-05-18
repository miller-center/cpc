class AddDescrptionToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :description, :text
    add_column :organizations, :contact_info, :text
    add_column :organizations, :onboarding, :text
    add_column :organizations, :notes_dates, :text
    add_column :organizations, :notes_text, :string
    add_column :organizations, :update_period, :text
    add_column :organizations, :api_known, :text
    add_column :organizations, :api_url, :text
  end
end
