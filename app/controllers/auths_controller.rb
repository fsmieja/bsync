class AuthsController < ApplicationController
  
  def index
    @auths = Auth.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def new
    @auth = Auth.new
  end
  
  def create
    @auth = Auth.new(params[:auth])
    if !@auth.save!
      flash.now[:error] = "Error creating auth"
      render 'new'
    else
      redirect_to auths_path, :notice => "Created auth"     
    end
  end
  
  def edit
    @auth = Auth.find(params[:id])  
  end
  
  def update
    @auth = Auth.find(params[:id])
    if @auth.update_attributes(params[:auth])
      flash.now[:success] = "Updated auth"
    else
      flash.now[:error] = "Error updating auth"
    end
    render 'edit'
  end

  
end
