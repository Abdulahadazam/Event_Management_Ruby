# app/admin/event_requests.rb
ActiveAdmin.register EventRequest do
  permit_params :name, :email, :phone, :event_title, :event_description,
                :preferred_date, :preferred_time, :is_remote, :venue_address,
                :city, :country, :platform, :meeting_link, :time_zone,
                :event_category_id, :status, :notes

  index do
    selectable_column
    id_column
    column :event_title
    column :name
    column :email
    column :location_type do |er|
      er.location_type
    end
    column :preferred_date
    column :status
    actions defaults: true do |er|
      item "Approve", approve_admin_event_request_path(er), method: :post if er.pending?
    end
  end

  member_action :approve, method: :post do
    event_request = EventRequest.find(params[:id])
    # Create real Event (light version) — adapt fields as per your Event model
    event = Event.create!(
      title: event_request.event_title,
      description: event_request.event_description,
      date: event_request.preferred_date,
      location: event_request.is_remote? ? (event_request.platform || "Remote") : event_request.venue_address,
      price: 0,
      # add other defaults as needed
    )

    # attach banner to event if present (if your Event has_one_attached :banner)
    if event_request.banner.attached? && event.respond_to?(:banner)
      event.banner.attach(event_request.banner.blob)
    end

    event_request.update!(status: :approved)

    # notify user
    EventRequestMailer.with(event_request: event_request, event: event).approved_email.deliver_later

    redirect_back fallback_location: admin_event_requests_path, notice: "EventRequest approved and Event created."
  end

  show do
    attributes_table do
      row :event_title
      row :name
      row :email
      row :status
      row :event_description
      row :preferred_date
      row :is_remote
      row :venue_address
      row :platform
      row :notes
      row :banner do |er|
        if er.banner.attached?
          image_tag url_for(er.banner.variant(resize_to_limit: [800, 300]))
        end
      end
    end
    active_admin_comments
  end
end
