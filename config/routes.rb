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
    resources :pieces
    resources :articles do
      member do
        post :up
        post :down
      end
    end
    resources :pieces
    match "/shipments/:id/mail/:style.:extension" => "communications#mail", :via => :get
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
        post :duplicate
        get :populate
        post :populate
        post :distribute
        delete :clear
      end
      collection do
        get :list_touchables
      end
    end
    resources :touchables, :except => [:show, :index, :new, :create]
    resources :untouchables
    match "/tab/:id" => "admin#toggle_tab", :via => :get
    namespace :delayed do
      resources :jobs, :only => [:index, :destroy]
    end
    root :to => "admin#index", :via => :get
  end

  match 'desabonnement/:key' => "home#unsubscribe", :as => :unsubscribe, :via => :get
  match 'message/:key' => "home#show", :as => :message
  match 'target/:key' => "home#target", :as => :target
  match 'opening/:key' => "home#opening", :as => :opening
  root :to => "home#index"
end
