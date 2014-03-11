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

  get '/users/update_quota', to: 'users#update_quota'
  
  get '/users/:uid/update_quota', to: 'users#update_quota',
                                  as: :user_update_quota,
                                  constraints: { uid: /[^\/]+/ }

  get '/groups', to: 'groups#index'

  get '/groups/new', to: 'groups#new'

  post '/groups/new', to: 'groups#save',
                     as: :groups_save

  post '/groups/list', to: 'groups#list'

  get '/groups/:cn/edit', to: 'groups#edit',
                          as: :groups_edit,
                          constraints: { cn: /[^\/]+/ }

  patch '/groups/:cn/edit', to: 'groups#update',
                             as: :groups_update,
                             constraints: { cn: /[^\/]+/ }

  get '/groups/:cn/delete', to: 'groups#delete',
                            as: :groups_delete,
                            constraints: { cn: /[^\/]+/ }

  get '/groups/page/:page', to: 'groups#index',
                           as: :groups_page

  get '/resources', to: 'resources#index'
  post '/resources', to: 'resources#index'

  get '/resources/new', to: 'resources#new'
  post '/resources/new', to: 'resources#save',
                         as: :resources_save

  get '/resources/:uid/edit', to: 'resources#edit',
                              as: :resources_edit,
                              constraints: { uid: /[^\/]+/ }

  patch '/resources/:uid/edit', to: 'resources#edit',
                                as: :resources_update,
                                constraints: { uid: /[^\/]+/ }

  get '/resources/:uid/delete', to: 'resources#delete',
                                as: :resources_delete,
                                constraints: { uid: /[^\/]+/ }

  get '/settings', to: 'settings#index'

  post '/settings/save', to: 'settings#save',
                         as: :settings_save

  get '/statistics', to: 'statistics#index'

  get '/statistics/export_csv', to: 'statistics#export_csv'

  if Rails.env.production?
    match '*not_found', to: 'application#error_404',
                        via: [ :get, :post ]
  end
end
