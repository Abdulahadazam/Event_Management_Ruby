ActiveAdmin.register Event do
  permit_params :title, :description, :date, :location

  index do
    selectable_column
    id_column
    column :title
    column :date
    column :location
    actions
  end

  form do |f|
    f.inputs "Event Details" do
      f.input :title
      f.input :description
      f.input :date, as: :datepicker
      f.input :location
    end
    f.actions
  end
end
