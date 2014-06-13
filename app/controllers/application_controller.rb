class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::RoutingError, :with => :render_not_found
  rescue_from ActionView::MissingTemplate, :with => :render_not_found
  rescue_from ActionView::Template::Error, :with => :render_error

  # CUSTOM EXCEPTION HANDLING
  # rescue_from StandardError do |e|
  #   error(e)
  # end

  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  protected

  def record_not_found
    render :text => "There is no record of that ID."
  end
  def render_error
    render "errors/500"
  end
  def render_not_found
    render "errors/404"
  end


end
