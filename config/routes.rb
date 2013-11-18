Zarafadashboard::Application.routes.draw do
  root 'z_dashboard#index'

  get '/auth', to: 'application#auth'
  post '/auth', to: 'application#auth'
  get '/logout', to: 'application#logout'

  get '/users', to: 'users#index'
  post '/users', to: 'users#index'

  get '/users/new', to: 'users#new'

  post '/users/list', to: 'users#list'

  post '/users/new', to: 'users#save',
                     as: :users_save
  
  get '/users/page/:page', to: 'users#index',
                           as: :users_page

  get '/users/:uid/edit', to: 'users#edit',
                          as: :users_edit,
                          constraints: { uid: /[^\/]+/ }

  patch '/users/:uid/edit', to: 'users#update',
                            as: :users_update,
                            constraints: { uid: /[^\/]+/ }

  get '/users/:uid/delete', to: 'users#delete',
                            as: :users_delete,
                            constraints: { uid: /[^\/]+/ }

  get '/groups', to: 'groups#index'

  get '/groups/new', to: 'groups#new'

  post '/groups/new', to: 'groups#save',
                     as: :groups_save

  get '/groups/:cn/edit', to: 'groups#edit',
                          as: :groups_edit,
                          constraints: { cn: /[^\/]+/ }

  patch '/groups/:cn/edit', to: 'groups#update',
                             as: :groups_update,
                             constraints: { cn: /[^\/]+/ }

  get '/groups/:cn/delete', to: 'groups#delete',
                            as: :groups_delete,
                            constraints: { cn: /[^\/]+/ }
end
