ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do

    # Quick Stats Summary
    columns do
      column do
        panel "Quick Stats" do
          div class: "dashboard-stats", style: "display: flex; justify-content: space-around; padding: 20px;" do
            div style: "text-align: center;" do
              h2 Event.count, style: "font-size: 36px; color: #3b82f6; margin: 0;"
              para "Total Events", style: "color: #6b7280; margin-top: 5px;"
            end

            div style: "text-align: center;" do
              h2 Ticket.paid.sum(:quantity), style: "font-size: 36px; color: #10b981; margin: 0;"
              para "Tickets Sold", style: "color: #6b7280; margin-top: 5px;"
            end

            div style: "text-align: center;" do
              h2 "$#{Ticket.paid.sum(:total_amount).round(2)}", style: "font-size: 36px; color: #f59e0b; margin: 0;"
              para "Total Revenue", style: "color: #6b7280; margin-top: 5px;"
            end

            div style: "text-align: center;" do
              h2 EventRequest.pending.count, style: "font-size: 36px; color: #ef4444; margin: 0;"
              para "Pending Requests", style: "color: #6b7280; margin-top: 5px;"
            end
          end
        end
      end
    end

    # Revenue and Ticket Charts
    columns do
      column do
        panel "Revenue Over Time (Last 30 Days)" do
          line_chart Ticket.paid.group_by_day(:created_at, last: 30).sum(:total_amount),
                     prefix: "$",
                     thousands: ",",
                     colors: ["#3b82f6"]
        end
      end

      column do
        panel "Tickets Sold Over Time (Last 30 Days)" do
          area_chart Ticket.group_by_day(:created_at, last: 30).sum(:quantity),
                     colors: ["#10b981"]
        end
      end
    end

    # Ticket Type and Category Distribution
    columns do
      column do
        panel "Revenue by Ticket Type" do
          pie_chart Ticket.paid.group(:ticket_type).sum(:total_amount),
                    prefix: "$",
                    donut: true,
                    colors: ["#3b82f6", "#f59e0b", "#ef4444"]
        end
      end

      column do
        panel "Events by Category" do
          column_chart Event.joins(:category).group("categories.name").count,
                       colors: ["#8b5cf6"]
        end
      end
    end

    # Payment Method and Event Status
    columns do
      column do
        panel "Payment Methods Used" do
          pie_chart Ticket.paid.group(:payment_method).count,
                    colors: ["#06b6d4", "#10b981", "#f59e0b"]
        end
      end

      column do
        panel "Ticket Status Distribution" do
          bar_chart Ticket.group(:status).count,
                    colors: ["#10b981", "#f59e0b", "#ef4444"]
        end
      end
    end

    # Top Events and Recent Activity
    columns do
      column do
        panel "Top 5 Events by Revenue" do
          table_for Ticket.paid.joins(:event).group("events.id", "events.title")
                          .select("events.title, SUM(tickets.total_amount) as revenue")
                          .order("revenue DESC")
                          .limit(5) do
            column("Event") { |ticket| ticket.title }
            column("Revenue") { |ticket| number_to_currency(ticket.revenue, unit: "$") }
          end
        end
      end

      column do
        panel "Top 5 Events by Tickets Sold" do
          table_for Ticket.joins(:event).group("events.id", "events.title")
                          .select("events.title, SUM(tickets.quantity) as total_tickets")
                          .order("total_tickets DESC")
                          .limit(5) do
            column("Event") { |ticket| ticket.title }
            column("Tickets Sold") { |ticket| ticket.total_tickets }
          end
        end
      end
    end

    # Recent Pending Event Requests
    if EventRequest.pending.any?
      panel "Pending Event Requests" do
        table_for EventRequest.pending.order(created_at: :desc).limit(10) do
          column("ID") { |req| link_to req.id, admin_event_request_path(req) }
          column("Event Title") { |req| req.event_title }
          column("Organizer") { |req| req.organizer_name }
          column("Date") { |req| req.preferred_date }
          column("Status") { |req| status_tag req.status }
          column("Actions") do |req|
            link_to "Approve", approve_admin_event_request_path(req), method: :post, class: "button"
          end
        end
      end
    end

    # Recent Ticket Purchases
    panel "Recent Ticket Purchases" do
      table_for Ticket.includes(:user, :event).order(created_at: :desc).limit(10) do
        column("ID") { |ticket| link_to "##{ticket.id}", admin_ticket_path(ticket) }
        column("Buyer") { |ticket| ticket.user&.email }
        column("Event") { |ticket| link_to ticket.event&.title, admin_event_path(ticket.event) }
        column("Type") { |ticket| status_tag ticket.ticket_type }
        column("Qty") { |ticket| ticket.quantity }
        column("Amount") { |ticket| number_to_currency(ticket.total_amount, unit: "$") }
        column("Status") { |ticket| status_tag ticket.status, class: ticket.status }
        column("Date") { |ticket| ticket.created_at.strftime("%b %d, %Y") }
      end
    end

  end # content
end
