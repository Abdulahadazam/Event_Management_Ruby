

pin "application"

# Hotwire packages
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" 
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.20
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.20
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.1.100

# Local controller files
pin "./controllers/dropdown_controller"
pin "./controllers/event_request_controller"
pin "./controllers/events_controller"
