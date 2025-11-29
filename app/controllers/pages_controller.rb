class PagesController < ApplicationController
  def home
    @events = Event.all.order(created_at: :desc)
  end
end


  def about
  end