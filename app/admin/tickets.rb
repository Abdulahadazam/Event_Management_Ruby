require 'csv'

ActiveAdmin.register Ticket do
  menu priority: 5

  permit_params :user_id, :event_id, :registration_id, :quantity, :total_amount,
                :status, :payment_method, :payment_id, :ticket_type

  # Index page - List all tickets
  index do
    selectable_column
    id_column

    column "Ticket #", :id do |ticket|
      link_to "##{ticket.id}", admin_ticket_path(ticket)
    end

    column "Buyer", :user do |ticket|
      link_to ticket.user.email, admin_user_path(ticket.user) if ticket.user
    end

    column "Event", :event do |ticket|
      link_to ticket.event.title, admin_event_path(ticket.event) if ticket.event
    end

    column :ticket_type do |ticket|
      status_tag ticket.ticket_type, class: case ticket.ticket_type
        when 'VIP' then 'warning'
        when 'Premium' then 'error'
        else 'ok'
      end
    end

    column :quantity

    column "Total Amount" do |ticket|
      number_to_currency(ticket.total_amount, unit: "$")
    end

    column :status do |ticket|
      status_tag ticket.status, class: case ticket.status
        when 'paid' then 'ok'
        when 'pending' then 'warning'
        when 'cancelled' then 'error'
      end
    end

    column :payment_method
    column "Purchased On", :created_at

    actions
  end

  # Filters
  filter :user, label: 'Buyer'
  filter :event
  filter :ticket_type, as: :select, collection: Ticket::TICKET_TYPES
  filter :status, as: :select, collection: ['pending', 'paid', 'cancelled']
  filter :payment_method, as: :select, collection: ['credit_card', 'debit_card', 'paypal', 'cash']
  filter :total_amount
  filter :quantity
  filter :created_at, label: 'Purchase Date'

  # Show page - Individual ticket details
  show do
    panel "Ticket Information" do
      attributes_table_for ticket do
        row :id
        row "Buyer" do |t|
          link_to t.user.email, admin_user_path(t.user) if t.user
        end
        row "Buyer Name" do |t|
          t.user&.name || t.user&.email&.split('@')&.first&.titleize
        end
        row "Event" do |t|
          link_to t.event.title, admin_event_path(t.event) if t.event
        end
        row "Event Date" do |t|
          t.event&.date&.strftime("%B %d, %Y at %I:%M %p")
        end
        row "Registration" do |t|
          link_to "Registration ##{t.registration_id}", admin_registration_path(t.registration) if t.registration
        end
        row :ticket_type do |t|
          status_tag t.ticket_type
        end
        row :quantity
        row "Price per Ticket" do |t|
          number_to_currency(t.total_amount / t.quantity, unit: "$") if t.quantity > 0
        end
        row "Total Amount" do |t|
          number_to_currency(t.total_amount, unit: "$")
        end
        row :status do |t|
          status_tag t.status
        end
        row :payment_method
        row :payment_id
        row "QR Code Data" do |t|
          t.qr_code_data
        end
        row "Purchased On" do |t|
          t.created_at.strftime("%B %d, %Y at %I:%M %p")
        end
        row :updated_at
      end
    end

    panel "Ticket Actions" do
      if ticket.status == 'pending'
        text_node link_to 'Mark as Paid',
                          mark_paid_admin_ticket_path(ticket),
                          method: :post,
                          data: { confirm: 'Are you sure you want to mark this ticket as paid?' },
                          class: 'button'
        text_node ' '
      end

      if ticket.status != 'cancelled'
        text_node link_to 'Cancel Ticket',
                          cancel_admin_ticket_path(ticket),
                          method: :post,
                          data: { confirm: 'Are you sure you want to cancel this ticket?' },
                          class: 'button'
      end
    end

    active_admin_comments
  end

  # Form for creating/editing tickets
  form do |f|
    f.inputs "Ticket Details" do
      f.input :user, label: 'Buyer',
              as: :select,
              collection: User.all.map { |u| ["#{u.email} (#{u.name || 'No name'})", u.id] },
              include_blank: 'Select a buyer'

      f.input :event,
              as: :select,
              collection: Event.all.map { |e| ["#{e.title} - #{e.date.strftime('%b %d, %Y')}", e.id] },
              include_blank: 'Select an event'

      f.input :registration,
              as: :select,
              collection: Registration.all.map { |r| ["Registration ##{r.id} - #{r.user&.email}", r.id] },
              include_blank: 'Select a registration (optional)',
              hint: 'Link to existing registration if applicable'

      f.input :ticket_type,
              as: :select,
              collection: Ticket::TICKET_TYPES,
              include_blank: false

      f.input :quantity,
              hint: 'Number of tickets'

      f.input :total_amount,
              hint: 'Total price for all tickets'

      f.input :status,
              as: :select,
              collection: ['pending', 'paid', 'cancelled'],
              include_blank: false

      f.input :payment_method,
              as: :select,
              collection: ['credit_card', 'debit_card', 'paypal', 'cash'],
              include_blank: 'Select payment method'

      f.input :payment_id,
              hint: 'Payment transaction ID (if applicable)'
    end

    f.actions
  end

  # Custom member actions
  member_action :mark_paid, method: :post do
    resource.update(status: 'paid')
    redirect_to admin_ticket_path(resource), notice: "Ticket marked as paid"
  end

  member_action :cancel, method: :post do
    resource.update(status: 'cancelled')
    redirect_to admin_ticket_path(resource), notice: "Ticket cancelled"
  end

  # Scope filters
  scope :all, default: true
  scope :paid, -> { where(status: 'paid') }
  scope :pending, -> { where(status: 'pending') }
  scope :cancelled, -> { where(status: 'cancelled') }

  # Custom collection actions
  action_item :download_report, only: :index do
    link_to 'Download CSV Report', download_report_admin_tickets_path(format: :csv)
  end

  collection_action :download_report, method: :get do
    @tickets = Ticket.includes(:user, :event).all

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['Ticket ID', 'Buyer Email', 'Buyer Name', 'Event Title', 'Event Date',
              'Ticket Type', 'Quantity', 'Total Amount', 'Status', 'Payment Method',
              'Payment ID', 'Purchase Date']

      @tickets.each do |ticket|
        csv << [
          ticket.id,
          ticket.user&.email,
          ticket.user&.name,
          ticket.event&.title,
          ticket.event&.date,
          ticket.ticket_type,
          ticket.quantity,
          ticket.total_amount,
          ticket.status,
          ticket.payment_method,
          ticket.payment_id,
          ticket.created_at
        ]
      end
    end

    send_data csv_data, filename: "tickets_report_#{Date.today}.csv"
  end
end
