// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

const application = Application.start()

import DropdownController from "./controllers/dropdown_controller"
import EventRequestController from "./controllers/event_request_controller"
import EventsController from "./controllers/events_controller"
import TicketBookingController from "./controllers/ticket_booking_controller"
import TicketPurchaseController from "./controllers/ticket_purchase_controller"
import EventMapController from "./controllers/event_map_controller"
import BannerCarouselController from "./controllers/banner_carousel_controller"
import MapModalController from "./controllers/map_modal_controller"


application.register("dropdown", DropdownController)
application.register("event-request", EventRequestController)
application.register("events", EventsController)
application.register("ticket-booking", TicketBookingController)
application.register("ticket-purchase", TicketPurchaseController)
application.register("event-map", EventMapController)
application.register("banner-carousel", BannerCarouselController)
application.register("map-modal", MapModalController) 
        