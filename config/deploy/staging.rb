# -*- encoding : utf-8 -*-
set :stage, :development
set :branch, 'master'
set :rvm_type, :user
set :rvm_ruby_version, '2.1.0'
set :deploy_user, 'deploy'

server '123.57.210.52', user: 'deploy', roles: %w{web app db}

set :deploy_to, "/srv/www/Freesia"
set :rails_env, :development
