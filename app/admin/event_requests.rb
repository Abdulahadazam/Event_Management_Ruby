ActiveAdmin.register EventRequest do
  permit_params :organizer_name, :organizer_email, :organizer_phone, :event_title, :event_description,
                :preferred_date, :preferred_time, :is_remote, :venue_address,
                :city, :country, :platform, :meeting_link, :time_zone,
                :category_id, :status, :notes, :banner, :ticket_price, :event_capacity


  filter :event_title
  filter :organizer_name
  filter :organizer_email
  filter :organizer_phone
  filter :status, as: :select, collection: -> { EventRequest.statuses }
  filter :preferred_date
  filter :is_remote
  filter :city
  filter :country
  filter :created_at

  
  remove_filter :banner_attachment, :banner_blob, :category

  scope :all, default: true
  scope :pending
  scope :approved
  scope :rejected

  index do
    selectable_column
    id_column
    column :event_title
    column :organizer_name
    column :organizer_email
    column :location_type
    column :preferred_date
    column :status do |er|
      status_tag er.status, class: er.status
    end
    
    actions defaults: true do |er|
      if er.pending?
        item "Approve", approve_admin_event_request_path(er), method: :post, class: "member_link"
        item "Reject", reject_admin_event_request_path(er), method: :post, class: "member_link", 
             data: { confirm: "Are you sure you want to reject this request?" }
      end
    end
  end

  member_action :approve, method: :post do
    event_request = EventRequest.find(params[:id])

    ActiveRecord::Base.transaction do
      event = Event.create!(
        title: event_request.event_title,
        description: event_request.event_description,
        date: event_request.preferred_date,
        location: event_request.is_remote? ? (event_request.platform || "Remote") : event_request.venue_address,
        price: event_request.ticket_price || 0,
        category_id: event_request.category_id,
        organizer_name: event_request.organizer_name,
        organizer_email: event_request.organizer_email,
        organizer_phone: event_request.organizer_phone,
        event_request_id: event_request.id
      )

      if event_request.banner.attached? && event.respond_to?(:banner)
        event.banner.attach(event_request.banner.blob)
      end

      # Create tickets based on ticket type selection
      if event_request.has_multiple_ticket_types? && event_request.ticket_types_data.present?
        # Create tickets for each type
        event_request.ticket_types_data.each do |ticket_type, price|
          Ticket.create!(
            event: event,
            ticket_type: ticket_type,
            price: price,
            available_quantity: (event_request.event_capacity || 100) / event_request.ticket_types_data.size
          )
        end
      else
        # Create a single standard ticket
        Ticket.create!(
          event: event,
          ticket_type: 'Standard',
          price: event_request.ticket_price || 0,
          available_quantity: event_request.event_capacity || 100
        )
      end

      event_request.update!(status: :approved)

      
      EventRequestMailer.with(event_request: event_request, event: event).approved_email.deliver_later
    end

    redirect_to admin_event_requests_path, notice: "Event request approved and event created successfully! Approval email sent to organizer."
  rescue => e
    redirect_to admin_event_requests_path, alert: "Error approving request: #{e.message}"
  end

  member_action :reject, method: :post do
    event_request = EventRequest.find(params[:id])
    rejection_reason = params[:rejection_reason] || "Unfortunately, we cannot approve your event request at this time."

    event_request.update!(status: :rejected)

    
    EventRequestMailer.with(
      event_request: event_request,
      rejection_reason: rejection_reason
    ).rejected_email.deliver_later

    redirect_to admin_event_requests_path, notice: "Event request rejected. Rejection email sent to organizer."
  rescue => e
    redirect_to admin_event_requests_path, alert: "Error rejecting request: #{e.message}"
  end

  show do
    attributes_table do
      row :event_title
      row :organizer_name
      row :organizer_email
      row :organizer_phone
      row :status do |er|
        status_tag er.status
      end
      row :event_description
      row :preferred_date
      row :preferred_time
      row :location_type
      row :is_remote
      row :venue_address
      row :city
      row :country
      row :platform
      row :meeting_link
      row :time_zone
      row :has_multiple_ticket_types do |er|
        er.has_multiple_ticket_types? ? "Yes (Multiple Types)" : "No (Single Type)"
      end
      row :ticket_pricing do |er|
        if er.has_multiple_ticket_types? && er.ticket_types_data.present?
          content_tag(:div) do
            er.ticket_types_data.map do |type, price|
              content_tag(:div, "#{type}: $#{price}", style: "margin-bottom: 5px;")
            end.join.html_safe
          end
        else
          er.ticket_price.to_f > 0 ? "$#{er.ticket_price}" : "Free"
        end
      end
      row :event_capacity
      row :category
      row :notes
      row :banner do |er|
        if er.banner.attached?
          image_tag url_for(er.banner.variant(resize_to_limit: [800, 300]))
        end
      end
      row :created_at
      row :updated_at
    end
    
    panel "Actions" do
      if event_request.pending?
        link_to "Approve Request", approve_admin_event_request_path(event_request), 
                method: :post, class: "button", 
                data: { confirm: "Create event and approve this request?" }
        text_node " "
        link_to "Reject Request", reject_admin_event_request_path(event_request), 
                method: :post, class: "button", 
                data: { confirm: "Are you sure you want to reject?" }
      end
    end
    
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :organizer_name
      f.input :organizer_email
      f.input :organizer_phone
      f.input :event_title
      f.input :event_description
      f.input :category
      f.input :preferred_date, as: :datepicker
      f.input :preferred_time
      f.input :is_remote
      f.input :venue_address
      f.input :city
      f.input :country
      f.input :platform
      f.input :meeting_link
      f.input :time_zone
      f.input :ticket_price
      f.input :event_capacity
      f.input :status, as: :select, collection: EventRequest.statuses.keys
      f.input :notes
      f.input :banner, as: :file
    end
    f.actions
  end
end