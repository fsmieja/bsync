class ProjectsController < ApplicationController
  
  include ApplicationHelper
  before_filter :authenticate_api
  
  def index
    @projects = Project.where("basecamp_id IS NULL")
  end
  
  def index_basecamp
    @projects = Project.where("basecamp_id IS NOT NULL")
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
    @num_messages = Message.get_count(@project)
    @num_comments = Comment.get_count(@project)
    @num_tasks = Task.get_count(@project)
  end

  def import_all
    if !Project.import_all_from_basecamp
      redirect_to root_path, :error => "Error importing all projects"
    end
    redirect_to root_path, :notice => "Successfully imported all projects"
  end  

  def discover
    startnum = Project.all.count
    if !Project.discover_new_from_basecamp
      redirect_to root_path, :error => "Error importing new projects"
    end
    additional_num = Project.all.count-startnum
    redirect_to root_path, :notice => additional_num > 0 ? "Successfully imported #{additional_num} new projects" : "No new projects to import"
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
