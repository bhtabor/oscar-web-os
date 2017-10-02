class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.where.not(short_name: 'cwd').order(:created_at)
    redirect_to dashboards_url(subdomain: Organization.current.short_name) if user_signed_in?
  end

  def robots
    robots = File.read(Rails.root + "config/robots/#{Rails.env}.txt")
    render text: robots, layout: false, content_type: 'text/plain'
  end
end
