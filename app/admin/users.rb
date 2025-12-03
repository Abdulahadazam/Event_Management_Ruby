ActiveAdmin.register User do
  config.filters = true

  permit_params :email, :role, :password, :password_confirmation

  
  remove_filter :reset_password_token
  remove_filter :reset_password_sent_at
  remove_filter :remember_created_at
  remove_filter :encrypted_password
  remove_filter :confirmation_token
  remove_filter :confirmed_at
  remove_filter :confirmation_sent_at
  remove_filter :unconfirmed_email

  
  remove_filter :registrations

  index do
    selectable_column
    id_column
    column :email
    column :role
    column :created_at
    actions
  end

  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :role, as: :select, collection: ["attendee", "organizer", "admin"]
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
