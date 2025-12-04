class EventsController < ApplicationController
  
  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
    
    if params[:success]
      flash.now[:notice] = "Payment successful! Your ticket has been confirmed."
    elsif params[:canceled]
      flash.now[:alert] = "Payment was canceled."
    end
  end
end