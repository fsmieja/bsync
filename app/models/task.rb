class Task < ActiveRecord::Base
  belongs_to :project
  has_many :comments, :dependent => :destroy
  
  def self.get_count(proj)
    tasks = find_all_by_project_id(proj.id)
    if proj.basecamp_id and tasks.empty?  # not been imported yet
      tasks = []
      todo_lists = Basecamp::TodoList.find(:all, :params => { :project_id => proj.basecamp_id })
      todo_lists.each do |todo_list|
        tasks += Basecamp::TodoItem.find(:all, :params => { :todo_list_id => todo_list.id })
      end
    else
      return 0
    end
    tasks.count
  end  


  def self.import_all_from_basecamp_project project
    Task.destroy_all(:project_id => project.id)
    todo_lists = Basecamp::TodoList.find(:all, :params => { :project_id => project.basecamp_id })
    bc_list = []
    todo_lists.each do |todo_list|
      bc_list += Basecamp::TodoItem.find(:all, :params => { :todo_list_id => todo_list.id })
    end
    bc_list.each do |bct|
      t = Basecamp::TodoItem.find(bct.id)
      task = project.tasks.build
      task.copy_fields_from_basecamp(t)
      if !task.save!
        return false
      end
    end
    true
  end
    
  def self.discover_new_from_basecamp(project)
    todo_lists = Basecamp::TodoList.find(:all, :params => { :project_id => project.basecamp_id })
    bc_list = []
    todo_lists.each do |todo_list|
      bc_list += Basecamp::TodoItem.find(:all, :params => { :todo_list_id => todo_list.id })
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
    end
    true
  end
      
  def copy_fields_from_basecamp(basecamp_task, summary=false)
    self.start_on = basecamp_task.created_on
    self.complete_on = basecamp_task.due_at
    self.basecamp_id = basecamp_task.id
    if !summary
      self.content = basecamp_task.content
      if basecamp_task.attributes.has_key? "responsible_party_name"
        self.owner = basecamp_task.responsible_party_name
      end
      self.creator = basecamp_task.creator_name
    end
    true
  end  


end