class CommentsController < ApplicationController
  include   ApplicationHelper

  helper_method :sort_column, :sort_direction
  
  def index_message
    @per_page = params[:per_page] ||  20
    order_str = sort_column + " "  + sort_direction
    @message = Message.find(params[:id])    
    @comments = @message.comments.order(order_str).page(params[:page]).per_page(@per_page)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  def index_task
    @per_page = params[:per_page] ||  20
    order_str = sort_column + " "  + sort_direction
    @task = Task.find(params[:id])    
    @comments = @task.comments.order(order_str).page(params[:page]).per_page(@per_page)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  def index_project
    @per_page = params[:per_page] ||  20
    @project = Project.find(params[:id])
    order_str = sort_column + " "  + sort_direction
    @comments = Comment.joins( "LEFT JOIN `messages` ON `messages`.`id` = `comments`.`message_id` LEFT JOIN `tasks` ON `tasks`.`id` = `comments`.`task_id`")
                       .where([ "messages.project_id = #{params[:id]} or tasks.project_id = #{params[:id]}" ]).order(order_str).page(params[:page]).per_page(@per_page)      
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  def show
    @comment = Comment.find(params[:id])
    @message = @comment.message
    @actions = get_actions(@comment.content)
    @events = get_events(@comment.content)
    @tags    = @comment.tags
    @all_tags = (@comment.project.message_tags + @comment.project.comment_tags).uniq

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  def new
    @message = Message.find(params[:id])
    @comment = Comment.new
  end
  
  def create
    @message = Message.find(params[:id])
    @comment = @message.comments.build(params[:comment])
    if !@comment.save!
      flash.now[:error] = "Error creating comment"
      render 'new'
    else
      redirect_to message_comments_path(@message), :notice => "Created comment"     
    end
  end
  
  def destroy
    comment = Comment.find(params[:id])
    @id = params[:id]
    comment.destroy
  end
    
  def add_comment
    @message = Message.find(params[:id])
    @comment = @message.comments.build(params[:comment])
    @added = false
    if !@comment.save!
      @msg = "Error creating comment"
    else
      @msg = "Added comment"
      @added = true
    end
    @num_comments = @message.comments.count
  end

  def edit
    @comment = Comment.find(params[:id])  
  end
  
  def update
    @comment = Comment.find(params[:id])  
    if @comment.update_attributes(params[:comment])
      flash.now[:success] = "Updated comment"
    else
      flash.now[:error] = "Error updating comment"
    end
    render 'edit'
  end
  
  def tag
    @added = false
    comment = Comment.find(params[:id])  
        
    t = Tag.find_or_create_tag(params[:new_tag])
    if !t
      @tag_message = "Tag must be at least 2 characters long"
    else
      if comment.tags.include? t
        @tag_message = "Already have that tag"
      else        
        t.update_attribute(:last_used_at, Time.now.utc)   
        comment.tags << t
        @tag_message = "Added tag"
        @added = true
      end
    end
    @tags = comment.tags 
    @new_tag = t
  end
  
  def remove_tag
    @removed = false
    tag_id = params[:tag_id]
    comment = Comment.find(params[:id])  
    tag = comment.tags.find(tag_id)
    rescue
      @tag_message = "Not able to remove tag"
    else
      comment.tags.delete(tag)  
      @removed = true
      @remove_tag = tag_id
      @tags = comment.tags
  end
  
  def import_all_for_project
    project = Project.find(params[:id])
    if !import_all_message_comments_for_project(params[:id])
      flash[:error] =  "There was a problem importing the comments from messages"
    elsif !import_all_task_comments_for_project(params[:id])
      flash[:error] =  "There was a problem importing the comments from tasks"
    else
      flash[:success] =  "Comments imported successfully"
    end
    redirect_to project_comments_path(project.id)
  end

  def import_all_for_message
    if Comment.import_all_from_basecamp_message(Message.find(params[:id]))
      flash[:success] = "Imported comments successfully"
    else
      flash[:error] = "There was a problem importing the comments"
    end
    redirect_to message_comments_path(params[:id])
  end

  def import_all_for_task
    if Comment.import_all_from_basecamp_task(Task.find(params[:id]))
      flash[:success] = "Imported comments successfully"
    else
      flash[:error] = "There was a problem importing the comments"
    end
    redirect_to task_comments_path(params[:id])
  end

  def import
    comment.copy_fields_from_basecamp Basecamp::Comment.find(params[:id])
    if comment.save!
      flash[:success] = "Imported comment successfully"
    else
      flash[:error] = "There was a problem importing the comment"
    end
    redirect_to message_comments_path(comment.message)
  end
  
  def reimport
    comment = Comment.find(params[:id])
    comment.copy_fields_from_basecamp(Basecamp::Comment.find(comment.basecamp_id))    
    if comment.save!
      flash[:success] = "Re-Imported comment successfully"
    else
      flash[:error] = "There was a problem re-importing the comment"
    end
    redirect_to message_comments_path(comment.message)
  end
  
  private
  
  def import_all_message_comments_for_project(project_id)
    messages = Message.find_all_by_project_id(project_id)
    messages.each do |m|
      if !Comment.import_all_from_basecamp_message(m)
        return false
      end
    end
    true
  end

  def import_all_task_comments_for_project(project_id)
    tasks = Task.find_all_by_project_id(project_id)
    tasks.each do |t|
      if !Comment.import_all_from_basecamp_task(t)
        return false
      end
    end
    true
  end

  # def copy_comment_from_basecamp basecamp_comment, com_list=nil
    # if !com_list.nil?
      # com_list.each do |c|
        # if c.basecamp_id == basecamp_comment.id
          # return nil
        # end
      # end
    # end
    # comment = Comment.new
    # comment.copy_fields_from_basecamp(basecamp_comment)
  # end

  

  def sort_column
      Comment.column_names.include?(params[:sort]) ? params[:sort] : "posted_on"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
  
end
