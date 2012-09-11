Sagitta::Application.routes.draw do
  devise_for :users, :path_prefix => 'auth'
  scope "/admin" do
    resources :newsletters do
      collection do
        get :list_rubrics
        get :list_communications
      end
    end
    resources :newsletter_rubrics, :path => "newsletter-rubrics"
    resources :articles do
      member do
        post :up
        post :down
      end
    end
    resources :pieces
    resources :users do
      collection do
        get :list
        get :list_communications
        get :list_untouchables
        get :list_newsletters
      end
    end
    resources :communications, :except => [:index] do
      member do
        get :populate
        post :populate
        post :distribute
        delete :clear
      end
      collection do
        get :list_touchables
      end
    end
    resources :touchables, :except => [:show, :index]
    resources :untouchables, :except => [:show, :index]
    root :to => "admin#index", :via => :get
  end

  match 'desabonnement/:key' => "home#unsubscribe", :as => :unsubscribe, :via => :get
  match ':key' => "home#show",  :as => :message
  root :to => "home#index"
end
