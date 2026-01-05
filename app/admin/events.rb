ActiveAdmin.register Event do
  permit_params :title, :description, :date, :location, :price, :category_id, :banner,
                :organizer_name, :organizer_email, :organizer_phone,
                :is_remote, :venue_address, :city, :country, :platform, :meeting_link, :time_zone,
                :preferred_time, :event_capacity, :has_multiple_ticket_types, :notes,
                :standard_ticket_price, :vip_ticket_price, :premium_ticket_price

  # Scopes to filter events by source
  scope :all, default: true
  scope "Approved Requests", :from_requests do |events|
    events.where.not(event_request_id: nil)
  end
  scope "Manually Created", :manual do |events|
    events.where(event_request_id: nil)
  end
  scope "Remote Events", :remote do |events|
    events.where(is_remote: true)
  end
  scope "Physical Events", :physical do |events|
    events.where(is_remote: [false, nil])
  end

  index do
    selectable_column
    id_column

    column :title do |event|
      link_to event.title, admin_event_path(event)
    end

    column "Source" do |event|
      if event.from_event_request?
        status_tag "Approved Request", class: "ok"
      else
        status_tag "Manual", class: "warning"
      end
    end

    column "Location Type" do |event|
      event.is_remote? ? status_tag("Remote", class: "info") : status_tag("Physical", class: "default")
    end

    column :category
    column :date

    column "Location/Platform" do |event|
      if event.is_remote?
        event.platform || "Remote"
      else
        event.location
      end
    end

    column "Price" do |event|
      if event.has_multiple_ticket_types? && event.ticket_types_data.present?
        "Multiple (from $#{event.ticket_types_data.values.min})"
      else
        number_to_currency(event.price, unit: "$")
      end
    end

    column "Capacity" do |event|
      event.event_capacity || "Unlimited"
    end

    column "Attendees" do |event|
      event.attendees_count
    end

    actions
  end

  filter :title
  filter :category
  filter :date
  filter :location
  filter :organizer_name
  filter :organizer_email
  filter :is_remote, as: :select, collection: [["Physical", false], ["Remote", true]]
  filter :city
  filter :country
  filter :price
  filter :event_capacity
  filter :created_at

  show do
    panel "Event Information" do
      attributes_table_for event do
        row :id

        row "Source" do |e|
          if e.from_event_request?
            link_to "Approved Request ##{e.event_request_id}", admin_event_request_path(e.event_request_id)
          else
            status_tag "Manually Created", class: "warning"
          end
        end

        row :title
        row :category
        row :description
        row :date
        row :preferred_time

        row "Location Type" do |e|
          e.is_remote? ? "Remote Event" : "Physical Event"
        end

        if event.is_remote?
          row :platform
          row :meeting_link do |e|
            if e.meeting_link.present?
              link_to e.meeting_link, e.meeting_link, target: "_blank"
            end
          end
          row :time_zone
        else
          row :location
          row :venue_address
          row :city
          row :country
        end

        row "Ticket Pricing" do |e|
          if e.has_multiple_ticket_types? && e.ticket_types_data.present?
            content_tag(:div) do
              e.ticket_types_data.map do |type, price|
                content_tag(:div, "#{type}: $#{price}", style: "margin-bottom: 5px;")
              end.join.html_safe
            end
          else
            e.price.to_f > 0 ? number_to_currency(e.price, unit: "$") : "Free"
          end
        end

        row :event_capacity do |e|
          e.event_capacity || "Unlimited"
        end

        row "Current Attendees" do |e|
          e.attendees_count
        end

        row "Organizer Name" do |e|
          e.organizer_name || "N/A"
        end

        row "Organizer Email" do |e|
          e.organizer_email || "N/A"
        end

        row "Organizer Phone" do |e|
          e.organizer_phone || "N/A"
        end

        row :notes

        row "Banner" do |e|
          url = e.banner_url
          url ? image_tag(url, height: 300) : "No Image"
        end

        row :created_at
        row :updated_at
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs "Event Source" do
      if f.object.persisted? && f.object.from_event_request?
        f.li do
          content_tag(:p, style: "background: #e8f5e9; padding: 10px; border-left: 4px solid #4caf50;") do
            "This event was created from ".html_safe +
            link_to("Event Request ##{f.object.event_request_id}", admin_event_request_path(f.object.event_request_id)) +
            ". Some fields are inherited from that request.".html_safe
          end
        end
      else
        f.li do
          content_tag(:p, style: "background: #fff3e0; padding: 10px; border-left: 4px solid #ff9800;") do
            "This is a manually created event. Fill in all required fields below.".html_safe
          end
        end
      end
    end

    f.inputs "Organizer Information" do
      f.input :organizer_name, hint: "Name of the event organizer"
      f.input :organizer_email, hint: "Contact email for the organizer"
      f.input :organizer_phone, hint: "Contact phone for the organizer"
    end

    f.inputs "Event Details" do
      f.input :title
      f.input :category
      f.input :description
      f.input :banner, as: :file, hint: f.object.banner.attached? ? "Current banner attached" : "Upload event banner"
    end

    f.inputs "Schedule & Mode" do
      f.input :date, as: :datepicker
      f.input :preferred_time, as: :string, placeholder: "HH:MM (e.g., 14:30)", hint: "Preferred time for the event"
      f.input :is_remote, as: :select,
              collection: [["Physical Event", false], ["Remote Event", true]],
              include_blank: false,
              hint: "Select whether this is a physical or remote event"
    end

    f.inputs "Location Details (Physical Events)", id: "physical-location" do
      f.input :location, hint: "Will be used for geocoding if coordinates not provided"
      f.input :venue_address, as: :string, hint: "Full venue address"
      f.input :city, as: :string
      f.input :country, as: :string
    end

    f.inputs "Online Meeting Details (Remote Events)", id: "remote-location" do
      f.input :platform, as: :string, placeholder: "e.g., Zoom, Google Meet", hint: "Platform for remote event"
      f.input :meeting_link, as: :url, hint: "Link to join the meeting"
      f.input :time_zone, as: :string, placeholder: "e.g., Asia/Karachi", hint: "Time zone for remote event"
    end

    f.inputs "Ticket Pricing" do
      f.input :has_multiple_ticket_types, as: :select,
              collection: [["Single Ticket Type", false], ["Multiple Ticket Types (Standard, VIP, Premium)", true]],
              include_blank: false,
              hint: "Choose whether to offer a single ticket price or multiple ticket types"

      f.input :price, as: :number, step: 0.01, min: 0,
              label: "Price (Single Ticket Type)",
              hint: "For single ticket type. Set to 0 for free events."

      f.input :standard_ticket_price, as: :number, step: 0.01, min: 0,
              hint: "For multiple ticket types: Standard ticket price (stored in ticket_types_data)"
      f.input :vip_ticket_price, as: :number, step: 0.01, min: 0,
              hint: "For multiple ticket types: VIP ticket price (stored in ticket_types_data)"
      f.input :premium_ticket_price, as: :number, step: 0.01, min: 0,
              hint: "For multiple ticket types: Premium ticket price (stored in ticket_types_data)"

      f.input :event_capacity, as: :number, min: 1,
              hint: "Maximum number of attendees. Leave blank for unlimited."
    end

    f.inputs "Additional Information" do
      f.input :notes, as: :text, hint: "Internal notes about this event"
    end

    f.actions
  end

  # Before save callback to handle ticket_types_data
  before_save do |event|
    if event.has_multiple_ticket_types?
      ticket_types = {}

      # Get prices from params (these are virtual attributes)
      standard_price = params[:event][:standard_ticket_price].to_f rescue 0
      vip_price = params[:event][:vip_ticket_price].to_f rescue 0
      premium_price = params[:event][:premium_ticket_price].to_f rescue 0

      ticket_types['Standard'] = standard_price if standard_price > 0
      ticket_types['VIP'] = vip_price if vip_price > 0
      ticket_types['Premium'] = premium_price if premium_price > 0

      event.ticket_types_data = ticket_types if ticket_types.any?
    end
  end

  # Custom action to view event request
  action_item :view_request, only: :show, if: proc{ event.from_event_request? } do
    link_to "View Original Request", admin_event_request_path(event.event_request_id)
  end
end
