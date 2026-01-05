class PagesController < ApplicationController
  def home
    @pagy, @events = pagy(Event.includes(:category).upcoming, items: 6)

    @categories = Category.all.order(:name)
  end

  def about
  end
end