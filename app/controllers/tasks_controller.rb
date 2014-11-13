class TasksController < ApplicationController
  include   ApplicationHelper
  
  helper_method :sort_column, :sort_direction

  def index
    @project = Project.find(params[:id])    

    @per_page = params[:per_page] ||  20
    order_str = sort_column + " "  + sort_direction
    @tasks = @project.tasks.order(order_str).page(params[:page]).per_page(@per_page)
 
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tasks }
    end
  end

  def show
    @task = Task.find(params[:id])
    comments = Basecamp::Comment.find(:all, :params => { :todo_item_id => @task.basecamp_id })
    @num_comments = comments.nil? ? 0 : comments.count
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  def discover
    project = Project.find(params[:id])
    startnum = project.tasks.count
    if !Task.discover_new_from_basecamp(project)
      flash[:error] = "Error importing new tasks"
    else
      additional_num = project.tasks.count-startnum
      flash[:notice] = additional_num > 0 ? "Successfully imported #{additional_num} new tasks" : "No new tasks to import"
    end
    redirect_to project_path(params[:id])
  end

  def destroy
    project = Project.find(params[:id])
    Task.destroy_project_tasks(project)    
    redirect_to project_path(project), :notice => "Removed tasks"     
  end

  def import_all
    project = Project.find(params[:id])
    if Task.import_all_from_basecamp_project(project)
      flash[:success] = "Imported tasks successfully"
    else
      flash[:error] = "There was a problem importing the tasks"
    end
    redirect_to project_path(project.id)
  end
 
  def reimport
    task = Task.find(params[:id])
    task.copy_fields_from_basecamp(Basecamp::TodoItem.find(task.basecamp_id))    
    if task.save!
      flash[:success] = "Re-Imported task successfully"
    else
      flash[:error] = "There was a problem re-importing the task"
    end
    redirect_to project_tasks_path(task.project_id)
  end
  
  private
   
  def sort_column
      Task.column_names.include?(params[:sort]) ? params[:sort] : "start_on"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
