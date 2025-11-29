// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Import and register controllers
import DropdownController from "./controllers/dropdown_controller"
import EventRequestController from "./controllers/event_request_controller"
import EventsController from "./controllers/events_controller"

application.register("dropdown", DropdownController)
application.register("event-request", EventRequestController)
application.register("events", EventsController)
