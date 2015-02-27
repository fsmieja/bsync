class ProjectsController < ApplicationController
  
  include ApplicationHelper
  before_filter :authenticate_api, :only => [:index_basecamp, :discover]
  before_filter :start_session
  
  def index
    @projects = Project.where("basecamp_id IS NULL")
    @bc_projects = Project.where("basecamp_id IS NOT NULL")
    #@auths = Auth.all
  end

  def new
    @project = Project.new
  end
  
  def create
    project = Project.new(params[:project])
    if !project.save!
      flash.now[:error] = "Error creating project"
      render 'new'
    else
      redirect_to projects_path, :notice => "Created project"     
    end
  end
  
  def edit
    @project = Project.find(params[:id])  
  end
  
  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      flash.now[:success] = "Updated project"
    else
      flash.now[:error] = "Error updating project"
    end
    render 'edit'
  end
  
  def show
    @project = Project.find(params[:id])
    @num_messages = @project.messages.count
    @num_events = @project.events.count
    @num_bc_messages = Message.get_bc_count(@project)
    @num_bc_events = Event.get_bc_count(@project)
    @num_message_comments = @project.message_comments.count
    @num_task_comments = @project.task_comments.count
    @num_bc_comments = 99#Comment.get_bc_count(@project)
    @num_tasks = @project.tasks.count
    @num_bc_tasks = Task.get_bc_count(@project)

  end

  def disconnect
    project = Project.find_by_basecamp_id(params[:id])
    project.disconnect_project
    if project.save!
      flash[:success] = "Disconnected project from basecamp"
    end
    redirect_to projects_path
    
  end
  
  def get_available_messages
    project = Project.find(params[:id])
    Message.get_bc_count(project, true)
    redirect_to project_path(project)
  end

  def get_available_events
    project = Project.find(params[:id])
    Event.get_bc_count(project, true)
    redirect_to project_path(project)
  end

  def get_available_tasks
    project = Project.find(params[:id])
    Task.get_bc_count(project, true)
    redirect_to project_path(project)
  end
  
  def import_all
    if !Project.import_all_from_basecamp
      redirect_to root_path, :error => "Error importing all projects"
    end
    redirect_to root_path, :notice => "Successfully imported all projects"
  end  

  def discover
    #startnum = Project.all.count
    num_new = Project.discover_new_from_basecamp
    if num_new<0
      redirect_to root_path, :error => "Error importing new projects"
    end
    #additional_num = Project.all.count-startnum
    redirect_to root_path, :notice => num_new > 0 ? "Successfully imported #{num_new} new projects" : "No new projects to import"
  end  
  
  def import
    proj = Project.new
    proj.copy_fields_from_basecamp(Basecamp::Project.find(params[:id]))
    if proj.save!
      flash[:success] = "Imported project successfully"
    else
      flash[:error] = "There was a problem importing the project"
    end
    redirect_to projects_path
  end
  
  def reimport
    project = Project.find(params[:id])
    project.copy_fields_from_basecamp(Basecamp::Project.find(project.basecamp_id))
    if project.save!
      flash[:success] = "Imported project successfully"
    else
      flash[:error] = "There was a problem importing the project"
    end
    redirect_to projects_path
  end
  
  
  private



end
