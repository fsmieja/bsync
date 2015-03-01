class Comment < ActiveRecord::Base
  belongs_to :message
  #belongs_to :task
  has_many :attachments, :dependent => :destroy
  has_many :comment_taggings
  has_many :tags, :through => :comment_taggings
  has_one :project, :through => :message
  #has_one :project, :through => :task
  
  def self.get_count(proj)
    if !proj.comments.nil?
      return proj.comments.count  
    end
    return 0
  end  
  
    def self.get_bc_count(proj, from_bc = false)
    num = 0
    if proj.basecamp_id   
      if from_bc
        messages = get_all_bc_messages_in_project(proj)
        num = messages.count
        proj.available_messages = num
        proj.save!
      else
        num = proj.available_messages
      end
    end
    num
  end
  
  def self.get_bc_count(proj)
    num = 0
    if proj.basecamp_id   # total available
      messages = Message.get_all_bc_messages_in_project(proj)
      messages.each do |m|
        comments = Basecamp::Comment.find(:all, :params => { :post_id => m.id} )
        if !comments.nil? 
          num += comments.count
        end
      end

      tasks = Task.get_all_bc_tasks_in_project(proj)
      tasks.each do |t|
        comments = Basecamp::Comment.find(:all, :params => { :todo_item_id => t.id} )
        if !comments.nil? 
          num += comments.count
        end
      end

    end
    return num
  end
  

  def self.discover_new_from_basecamp_message(message, max_number=20)
    bc_list = Basecamp::Comment.find(:all, :params => { :post_id => message.basecamp_id})
    bc_list.each do |bcc|
      if !find_by_basecamp_id(bcc.id)
        i=i+1
        if i==max_number
          return true
        end
        cmt = message.comments.build
        cmt.copy_fields_from_basecamp(bcc)
        if !cmt.save!
          return false
        end
      end 
    end
    message.update_attribute(:num_comments,message.comments.count) 
    true
  end  
  
  def import_all_for_project(project_id)
    import_all_message_comments_for_project(project_id) && import_all_task_comments_for_project(project_id)
  end
     
  def import_all_message_comments_for_project(project_id)
    messages = Message.find_all_by_project_id(project_id)
    messages.each do |m|
      if !Comment.import_all_from_basecamp_message(m)
        return false
      end
    end
    true
  end


  def discover_new_message_comments_for_project(project_id)
    messages = Message.find_all_by_project_id(project_id)
    messages.each do |m|
      if !Comment.discover_new_from_basecamp_message(m)
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


  def self.discover_new_from_basecamp_task task
    bc_list = Basecamp::Comment.find(:all, :params => { :todo_item_id => task.basecamp_id} )
    bc_list.each do |bcc|
      if !find_by_basecamp_id(bcc.id)
        cmt = task.comments.build
        cmt.copy_fields_from_basecamp(bcc)
        if !cmt.save!
          return false
        end
      end 
    end
    task.update_attribute(:num_comments,task.comments.count) 
    return true
  end
  
  def self.import_all_from_basecamp_message message
    Comment.destroy_all(:message_id => message.id)
    bc_list = Basecamp::Comment.find(:all, :params => { :post_id => message.basecamp_id} )
    #bc_list = Basecamp::Comment.archive(:params => { :post_id => message.basecamp_id} )
    bc_list.each do |bcm|
      if !import_comment(bcm, message)
        return false  
      end
    end
    message.update_attribute(:num_comments,message.comments.count)
    return true
  end

  def self.import_comment(c, message)
    cmt = Basecamp::Comment.find(c.id)
    comment = message.comments.build
    comment.copy_fields_from_basecamp(cmt)
    if !comment.save!
      return false
    end
    sleep 1
    true
  end


  def self.discover_new_from_basecamp_message message
    bc_list = Basecamp::Comment.find(:all, :params => { :post_id => message.basecamp_id} )
    #bc_list = Basecamp::Comment.archive(:params => { :post_id => message.basecamp_id} )
    bc_list.each do |bcm|
      if !find_by_basecamp_id(bcm.id)
        if !import_comment(bcm, message)
          return false  
        end
      end
    end
    message.update_attribute(:num_comments,message.comments.count)
    true
  end

  def self.import_all_from_basecamp_task task
    Comment.destroy_all(:task_id => task.id)
    bc_list = Basecamp::Comment.find(:all, :params => { :todo_item_id => task.basecamp_id} )
    bc_list.each do |bcm|
      cmt = Basecamp::Comment.find(bcm.id)
      comment = task.comments.build
      comment.copy_fields_from_basecamp(cmt)
      if !comment.save!
        return false
      end
      sleep(1)
    end
    task.update_attribute(:num_comments,task.comments.count) 
    return true
  end

  def copy_fields_from_basecamp basecamp_comment, summary=false
    self.posted_on = basecamp_comment.created_at
    if !summary
      self.content = basecamp_comment.body
      self.author = basecamp_comment.author_name
      self.basecamp_id = basecamp_comment.id
      if !basecamp_comment.attachments.empty?
        self.attachments.destroy_all
        return self.copy_attachments_from_basecamp(basecamp_comment.attachments)
      end      
    end
    true
  end  


  def copy_attachments_from_basecamp(basecamp_attachments)
      basecamp_attachments.each do |a|      
      attachment = self.attachments.build
      attachment.copy_fields_from_basecamp(a)
      if !attachment.save!
        return false
      end
    end
    self.num_attachments = basecamp_attachments.count
    true
  end  

end
