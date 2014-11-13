class MessagesController < ApplicationController
  include   MessagesHelper
  include   ApplicationHelper
  
  helper_method :sort_column, :sort_direction

  def index
    @project = Project.find(params[:id])    

    @per_page = params[:per_page] ||  20
    order_str = sort_column + " "  + sort_direction
    @messages = @project.messages.order(order_str).page(params[:page]).per_page(@per_page)
    add_tag_numbers_across_messages(@messages)
    @tags = (@project.message_tags + @project.message_comment_tags + @project.task_comment_tags).uniq
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  def new
    @project = Project.find(params[:id])
    @message = Message.new
  end
  
  def create
    @project = Project.find(params[:id])
    @message = @project.messages.build(params[:message])
    if !@message.save!
      flash.now[:error] = "Error creating note"
      render 'new'
    else
      redirect_to project_messages_path(@project), :notice => "Created note"     
    end
  end
  
  def edit
    @message = Message.find(params[:id])  
    @project = @message.project
  end
  
  def update
    @message = Message.find(params[:id])
    if @message.update_attributes(params[:message])
      flash.now[:success] = "Updated note"
    else
      flash.now[:error] = "Error updating note"
    end
    render 'edit'
  end
  
  def tag
    @added = false
    message = Message.find(params[:id])
        
    t = Tag.find_or_create_tag(params[:new_tag])
    if !t
      @tag_message = "Tag must be at least 2 characters long"
    else
      if message.tags.include? t
        @tag_message = "Already have that tag"
      else    
        t.update_attribute(:last_used_at, Time.now.utc)   
        message.tags << t
        @tag_message = "Added tag"
        @added = true
      end
    end
    @tags = message.tags 
    @new_tag = t
  end
  
  def remove_tag
    @removed = false
    tag_id = params[:tag_id]
    message = Message.find(params[:id])
    tag = message.tags.find(tag_id)
    rescue
      @tag_message = "Not able to remove tag"
    else
      message.tags.delete(tag)  
      @removed = true
      @remove_tag = tag_id
      @tags = message.tags
  end
    
  def show
    @message = Message.find(params[:id])
    if @message.content.nil?
      @message.content = ""
    end
    if @message.basecamp_id
      comments = Basecamp::Comment.find(:all, :params => { :post_id => @message.basecamp_id })
    else
      comments = @message.comments
    end
    @actions = get_actions(@message.content)
    @events = get_events(@message.content)
    @tags = @message.tags
    @all_tags = @message.project.message_tags.uniq
    #@questions = get_questions @message.content
    @num_comments = comments.nil? ? 0 : comments.count
    @comment = Comment.new
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  def import_all
    project = Project.find(params[:id])
    if Message.import_all_from_basecamp_project(project)
      flash[:success] = "Imported messages successfully"
    else
      flash[:error] = "There was a problem importing the messages"
    end
    redirect_to project_path(project.id)
  end
 
  def import
    message = copy_message_from_basecamp Basecamp::Post.find(params[:id])
    if message.save!
      flash[:success] = "Imported message successfully"
    else
      flash[:error] = "There was a problem importing the message"
    end
    redirect_to project_messages_path(message.project_id)
  end
  
  def reimport
    message = Message.find(params[:id])
    message.copy_fields_from_basecamp(Basecamp::Message.find(message.basecamp_id))    
    if message.save!
      flash[:success] = "Re-Imported message successfully"
    else
      flash[:error] = "There was a problem re-importing the message"
    end
    redirect_to project_messages_path(message.project_id)
  end
  
  def destroy
    project = Project.find(params[:id])
    Message.destroy_project_messages(project)    
    redirect_to project_path(project), :notice => "Removed messages"     
  end
  
  def discover
    project = Project.find(params[:id])
    startnum = project.messages.count
    if !Message.discover_new_from_basecamp(project)
      redirect_to project_messages_path(params[:id]), :error => "Error importing new messages"
    end
    additional_num = project.messages.count-startnum
    redirect_to project_path(params[:id]), :notice => additional_num > 0 ? "Successfully imported #{additional_num} new messages" : "No new messages to import"
  end  
  
  private
   
  def add_tag_numbers_across_messages(messages)
    tag_num = {}
    tags = []
    messages.each do |m|
      tags = (tags + m.tags + m.comment_tags).uniq
      m.add_tag_numbers(tag_num)
    end
    
    @tag_numbers = tag_num
    @tags = tags
  end
  
  def sort_column
      Message.column_names.include?(params[:sort]) ? params[:sort] : "posted_on"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
