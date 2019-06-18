Rails.application.routes.draw do

	get 'sessions/new'

	get 'users/new'

	root 'static_pages#home' 
	get '/home', to: 'static_pages#home'
	get '/help',to: 'static_pages#help'
	get '/contact',to: 'static_pages#contact'
	get '/about', to:'static_pages#about'
	get '/signup',to: 'users#new'

	get    '/login',   to: 'sessions#new'
	post   '/login',   to: 'sessions#create'
	delete '/logout',  to: 'sessions#destroy'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users , only: [:index, :new, :show, :create, :edit, :update, :destroy]
  # Demo ve Namespace
  # namespace :admin do
  # end
  resources :account_activations, only: [:edit]
end
