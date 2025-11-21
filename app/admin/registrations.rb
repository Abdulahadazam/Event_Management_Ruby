ActiveAdmin.register Registration do
  permit_params :user_id, :event_id, :status

  index do
    selectable_column
    id_column
    column :user
    column :event
    column :status
    column :created_at
    actions
  end

  filter :user
  filter :event
  filter :status
  filter :created_at

  show do
    attributes_table do
      row :id
      row :user
      row :event
      row :status
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :user
      f.input :event
      f.input :status
    end
    f.actions
  end
end
