class EventsController < ApplicationController
  include   ApplicationHelper

  helper_method :sort_column, :sort_direction

  def index
    @project = Project.find(params[:id])    

    @per_page = params[:per_page] ||  20
    order_str = sort_column + " "  + sort_direction
    @events = @project.events.order(order_str).page(params[:page]).per_page(@per_page)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def new
    @project = Project.find(params[:id])
    @event = Event.new
  end
  
  def create
    @project = Project.find(params[:id])
    @event = @project.events.build(params[:event])
    if !@event.save!
      flash.now[:error] = "Error creating event"
      render 'new'
    else
      redirect_to project_events_path(@project), :notice => "Created event"     
    end
  end
  
  def edit
    @event = Event.find(params[:id])  
    @project = @event.project
  end
  
  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash.now[:success] = "Updated event"
    else
      flash.now[:error] = "Error updating event"
    end
    render 'edit'
  end

  def show
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  def import_all
    project = Project.find(params[:id])
    if Event.import_all_from_basecamp_project(project)
      flash[:success] = "Imported events successfully"
    else
      flash[:error] = "There was a problem importing the events"
    end
    redirect_to project_path(project.id)
  end
 
  def import
    event = copy_event_from_basecamp Basecamp::Post.find(params[:id])
    if event.save!
      flash[:success] = "Imported event successfully"
    else
      flash[:error] = "There was a problem importing the event"
    end
    redirect_to project_events_path(event.project_id)
  end
  
  def reimport
    event = Event.find(params[:id])
    event.copy_fields_from_basecamp(Basecamp::Event.find(event.basecamp_id))    
    if event.save!
      flash[:success] = "Re-Imported event successfully"
    else
      flash[:error] = "There was a problem re-importing the event"
    end
    redirect_to project_events_path(event.project_id)
  end
  
  def destroy
    project = Project.find(params[:id])
    Event.destroy_project_events(project)    
    redirect_to project_path(project), :notice => "Removed events"     
  end
  
  def discover
    project = Project.find(params[:id])
    startnum = project.events.count
    if !Event.discover_new_from_basecamp(project)
      redirect_to project_events_path(params[:id]), :error => "Error importing new events"
    end
    additional_num = project.events.count-startnum
    redirect_to project_path(params[:id]), :notice => additional_num > 0 ? "Successfully imported #{additional_num} new events" : "No new events to import"
  end  
  
  private
  
    def sort_column
      Event.column_names.include?(params[:sort]) ? params[:sort] : "created_on"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
