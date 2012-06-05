OffsiteV3::Application.routes.draw do

  root :to => 'home_page#index'
  match '/login', to: 'sessions#new', as: 'login'
  match '/logout', to: 'sessions#destroy', as: 'logout'
  match '/auth/cas/callback' => 'sessions#create'
  match '/not_authorized', to: 'application#not_authorized', as: 'not_authorized'

  resources :sessions, only: [:new, :create, :destroy]
  resources :off_site_requests
  resource :users, :only => [:new, :create]

  #match '/app_monitor', to: 'app_monitor#index', as: 'check_app'
  #match '/app_monitor/test_exception', to: 'app_monitor#test_exception', to: 'check_exception'

  match '/ldap_search', to: 'ldap_search#index', as: 'ldap_search'
  match '/ldap_search/do_search', to: 'ldap_search#do_search', as: 'do_ldap_search'

  match '/admin', to: 'admin/admin#index', as: 'admin_root'
  match '/admin/login', to: 'admin/admin#index', as: 'admin_login'


  namespace :admin do
    resource :users,
             :except => "show",
             :collection => { :search => :get, :do_search => :get },
             :member => { :login => :get }
    resource :roles, :except => "roles"
    resource :ext_circumstances, :except => "show"
    resource :off_site_requests, :except => "show"
    resource :statuses, :except => "show"
  end


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
  # match ':controller(/:action(/:id))(.:format)'
end
