class Task < ActiveRecord::Base
  belongs_to :project
  has_many :comments, :dependent => :destroy
  
  def self.get_count(proj)
    if proj.tasks
      return proj.tasks.count
    end
    return 0
  end  
    
  def self.get_bc_count(proj, from_bc = false)
    num = 0
    if proj.basecamp_id   
      if from_bc
        tasks = get_all_bc_tasks_in_project(proj)
        num = tasks.count
        proj.available_tasks = num
        proj.save!
      else
        num = proj.available_tasks
      end
    end
    num
  end
  
  def self.get_all_bc_tasks_in_project(proj)
    tasks = []
    if proj.basecamp_id   # total available
      todo_lists = Basecamp::TodoList.find(:all, :params => { :project_id => proj.basecamp_id })
      todo_lists.each do |todo_list|
        tasks += Basecamp::TodoItem.find(:all, :params => { :todo_list_id => todo_list.id })
        sleep 0.1
      end
    end
    tasks 
  end


  def self.import_all_from_basecamp_project project
    Task.destroy_all(:project_id => project.id)
    todo_lists = Basecamp::TodoList.find(:all, :params => { :project_id => project.basecamp_id })
    bc_list = []
    todo_lists.each do |todo_list|
      bc_list += Basecamp::TodoItem.find(:all, :params => { :todo_list_id => todo_list.id })
      sleep 0.1
    end
    bc_list.each do |bct|
      t = Basecamp::TodoItem.find(bct.id)
      task = project.tasks.build
      task.copy_fields_from_basecamp(t)
      if !task.save!
        return false
      end
      sleep 0.1
    end
    true
  end
    
  def self.discover_new_from_basecamp(project)
    todo_lists = Basecamp::TodoList.find(:all, :params => { :project_id => project.basecamp_id })
    bc_list = []
    todo_lists.each do |todo_list|
      bc_list += Basecamp::TodoItem.find(:all, :params => { :todo_list_id => todo_list.id })
      sleep 0.1
    end
    bc_list.each do |bcm|
      if !find_by_basecamp_id(bcm.id)
        tsk = project.tasks.build
        t = Basecamp::TodoItem.find(bcm.id)
        tsk.copy_fields_from_basecamp(t)
        if !tsk.save!
          return false
        end
      end 
      sleep 0.1
    end
    true
  end
      
  def copy_fields_from_basecamp(basecamp_task, summary=false)
    
    self.start_on = basecamp_task.created_on
    self.complete_on = basecamp_task.due_at
    self.basecamp_id = basecamp_task.id
    self.complete = basecamp_task.completed
    if !summary
      self.content = basecamp_task.content
      if basecamp_task.attributes.has_key? "responsible_party_name"
        self.owner = basecamp_task.responsible_party_name
      end
      self.creator = basecamp_task.creator_name
    end
    true
  end  

  def self.destroy_project_tasks(project)
     Task.destroy_all(:project_id => project.id)
  end


end