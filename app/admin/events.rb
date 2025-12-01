ActiveAdmin.register Event do
  permit_params :title, :description, :date, :location, :price, :category_id, :banner

  index do
    selectable_column
    id_column
    column :title
    column :category
    column :date
    column :location
    column "Attendees" do |e|
      e.attendees_count
    end
    column "Banner" do |e|
      url = e.banner_url
      url ? image_tag(url, height: 60) : "No Image"
    end
    actions
  end

  filter :title
  filter :category
  filter :date
  filter :location

  show do
    attributes_table do
      row :id
      row :title
      row :category
      row :description
      row :date
      row :location
      row :price
      row "Attendees" do |e|
        e.attendees_count
      end
      row "Banner" do |e|
        url = e.banner_url
        url ? image_tag(url, height: 200) : "No Image"
      end
    end 
    active_admin_comments
  end  

  form do |f|
    f.inputs "Event Details" do
      f.input :title
      f.input :category
      f.input :description
      f.input :date, as: :datepicker
      f.input :location
      f.input :price
      f.input :banner, as: :file #, hint: f.object.banner_url ? image_tag(f.object.banner_url, height: 100) : "Upload banner"
    end
    f.actions
  end
end