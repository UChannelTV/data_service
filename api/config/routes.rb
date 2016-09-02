Rails.application.routes.draw do
  get '/auth/google/callback', to: 'sessions#create'

  use_doorkeeper do
    # it accepts :authorizations, :tokens, :applications and :authorized_applications
    controllers :applications => 'oauth_applications'
  end

  scope 'api/v1.0', defaults: { format: :json } do
    resources :videos do
      collection do
        get :list_status, :category
      end
      member do
        get :formatted
      end
    end

    resources :filler_videos do
      collection do
        get :find
      end
    end

    resources :video_uploads do
      collection do
        get :index
        post :create
        put :enable, :disable, :video
        delete :destroy
      end
    end
        
    resources :videos
    resources :filler_videos
    resources :youtube_uploads
    resources :vimeo_uploads
    resources :video_categories
  end

  scope 'admin' do 
    resources :filler_video_admin do
      collection do
        get :match_search
        post :index, :match_result
      end
    end

    resources :youtube_upload_admin do
      collection do
        post :index
      end
    end

    resources :vimeo_upload_admin do
      collection do
        post :index
      end
    end

    resources :video_admin do
      collection do
        post :index
      end
    end

    resources :video_admin
    resources :filler_video_admin
    resources :youtube_upload_admin
    resources :vimeo_upload_admin
    resources :video_category_admin
    resources :video_upload_admin
  end

  resources :users, only: [:index, :show, :edit, :update]
  resources :sessions, only: [:new, :create]
  resources :heartbeat, only: [:index]
  get '/logout' => 'sessions#destroy'
  
  root :to => "video_admin#index"
 
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
