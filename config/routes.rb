CrowdClub::Application.routes.draw do
  
  get "home/index"

  get "home/new"

  get "home/show"

  devise_for :users, :controllers => {:dashboard => "dashboard"}
  devise_scope :user do
    match 'crowdclub/api/dashboard' => "dashboard#index" ,:via => [:get, :post], :as => :user_dashboard
  end
  
=begin
  These routes defines the user related data retreival and updation. 
=end
   match 'crowdclub/api/get/user_data' => "me#get_user_data" , :via => :get
   match 'crowdclub/api/get/user_image/:user_name' => "me#get_user_image" , :via => :get
   match 'crowdclub/api/update/user_name_status' => "me#update_user_name_status" , :via => :post
   match 'crowdclub/api/update/user_location' => "me#update_user_location" , :via => :post
   match 'crowdclub/api/update/user_image' => "me#update_user_image" , :via => :post
   match 'crowdclub/api/add/location' => "me#add_new_location" , :via => :post
=begin
  These routes define user feed creation and view apis.
=end
  match 'crowdclub/api/create/user_feed' => "feeds#create_user_feed" , :via => :post
  match 'crowdclub/api/get/user_feed' => "feeds#get_user_feed" , :via => :get
  match 'crowdclub/api/get/category_list' => "feeds#get_category_list" , :via => :get
  
=begin
  These routes define buddy search for a logged in user. 
=end
  match 'crowdclub/api/search/buddies' => "buddies#search_buddies_by_location" , :via => :get

=begin
  These routes define buddy search for a logged in user. 
=end
  match 'crowdclub/api/add/buddies' => "buddies#add_buddies_to_friends_list" , :via => :get
    
=begin
  These routes implements feed related activities.
=end
   #match '*a', :to => 'application#no_route_found'
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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
  #root :to => 'dashboard#show'
end
