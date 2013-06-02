Basecamp::Application.routes.draw do

 root :to => 'projects#index'

  resources :tags do
    collection do
      put :delete_all
    end
  end
 match 'message/:id/comments', :to => 'comments#index_message', :as => "message_comments"
 match 'message/:id/new', :to => 'messages#new', :as => "new_project_message"
 match 'project/:id/comments', :to => 'comments#index_project', :as => "project_comments"
 match 'task/:id/comments',    :to => 'comments#index_task', :as => "task_comments"
 match 'project/:id/messages', :to => 'messages#index', :as => "project_messages"
 match 'project/:id/tasks',    :to => 'tasks#index', :as => "project_tasks"
 match 'projects/basecamp', :to => 'projects#index_basecamp', :as => "basecamp_projects"
 match 'message/:id/add_comment', :to => 'comments#add_comment', :as => "add_message_comment"

 resources :comments
 resources :messages
 resources :tasks
 resources :projects
 resources :words
 resources :tags

 match 'task/:id/import', :to => 'tasks#import', :as => "import_task"
 match 'task/:id/reimport', :to => 'tasks#reimport', :as => "reimport_task"
 match 'tasks/:id/import', :to => 'tasks#import_all', :as => "import_tasks"
 match 'tasks/:id/discover', :to => 'tasks#discover', :as => "discover_tasks"

 match 'comment/:id/import_for_message', :to => 'comments#import_all_for_message', :as => "import_message_comments"
 match 'comment/:id/reimport', :to => 'comments#reimport', :as => "reimport_comment"
 match 'comments/:id/import', :to => 'comments#import_all', :as => "import_comments"
 match 'comments/:id/tag', :to => 'comments#tag'
 match 'comment/:id/remove_tag', :to => 'comments#remove_tag', :as => "remove_comment_tag"

 match 'message/:id/import', :to => 'messages#import', :as => "import_message"
 match 'message/:id/reimport', :to => 'messages#reimport', :as => "reimport_message"
 match 'messages/:id/import', :to => 'messages#import_all', :as => "import_messages"
 match 'messages/:id/reimport', :to => 'messages#reimport_all', :as => "reimport_messages"
 match 'messages/:id/discover', :to => 'messages#discover', :as => "discover_messages"
 match 'messages/:id/tag', :to => 'messages#tag'
 match 'message/:id/remove_tag', :to => 'messages#remove_tag', :as => "remove_message_tag"
 
 
 match 'project/:id/import_comments', :to => 'comments#import_all_for_project', :as => "import_project_comments"
 match 'project/:id/import', :to => 'projects#import', :as => "import_project"
 match 'project/:id/reimport', :to => 'projects#reimport', :as => "reimport_project"
 match 'projects/import', :to => 'projects#import_all', :as => "import_projects"
 match 'projects/discover', :to => 'projects#discover', :as => "discover_projects"
 

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
