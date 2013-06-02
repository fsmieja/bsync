class TagsController < ApplicationController
  include   ApplicationHelper

  helper_method :sort_column, :sort_direction

  def index
    order_str = sort_column + " "  + sort_direction
    
    @unused_tags =  Tag.joins("left join message_taggings m on tags.id = m.tag_id left join comment_taggings c on tags.id = c.tag_id").where("m.id is null and c.id is null").order("name asc").uniq
    @used_tags = Tag.joins("left join message_taggings m on tags.id = m.tag_id left join comment_taggings c on tags.id = c.tag_id").where("m.id is not null or c.id is not null").order(order_str).uniq
  end
  
  def delete_all
    @removed = false
    @tag_ids = params[:tag_ids]
     if Tag.delete_all( {id: params[:tag_ids]})
       @removed = true
     else
       @error_messages = "Unable to complete delete request"
     end 
  end
  
  def destroy
    tag = Tag.find(params[:id])
    @id = params[:id]
    @removed = false
    msgs = Message.includes(:tags).where(:tags => { :id => @id })
    cmts = Comment.includes(:tags).where(:tags => { :id => @id })
    if msgs.count > 0 || cmts.count > 0
      @tag_message = "Unable to delete tag since it is being used"
    else
      tag.destroy
      @removed = true
    end
  end
  
  def show
    @tag = Tag.find(params[:id])  
    @messages = @tag.messages
    @comments = @tag.comments
    get_projects(@messages,@comments)  # sets @projects ad @project_numbers
  end
  
  def new
    @many = params[:many]
    @tag = Tag.new
  end
  
  def create
    if !Tag.create_tags(params[:tag][:name],params[:many])
      flash.now[:error] = "Error adding tag(s)"
      render 'new'
    else
      redirect_to tags_path, :notice => "Added new tag(s)"     
    end
  end
  
  def edit
    @tag = Tag.find(params[:id])  
  end
  
  def update
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      flash.now[:success] = "Updated tag"
    else
      flash.now[:error] = "Error updating tag"
    end
    render 'edit'
  end
  
  private
  
  def get_projects(messages,comments)
    projects = []
    project_count = {}
    if messages
      messages.each do |m|
        projects << m.project
        add_to_project_count(project_count,m.project_id)
      end
    end
    if comments
      comments.each do |c|
        projects << c.project
        add_to_project_count(project_count,c.message.project_id)
      end
    end
    @projects = projects.uniq
    @project_numbers = project_count
  end

  def add_to_project_count(project_count,id)
    if project_count[:project_id => id]
      project_count[:project_id => id] += 1
    else
      project_count[:project_id => id] = 1
    end
  end
  
  def sort_column
      if params[:sort]=="times_used"
        "times_used"
      else
        Tag.column_names.include?(params[:sort]) ? params[:sort] : "name"
      end
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
