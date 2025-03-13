class HomeController < ApplicationController
  before_action :authenticate_person!

  def index
  end
end 