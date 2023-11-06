### user
asfasafsfsafsafsaasf@gmail.com
123456


testeamiladress1@gmail.com
123456


# work with server
lsof -i :3000
kill -QUIT 13907


# 1

bin/rails assets:precompile
rails assets:clean
rake assets:clobber
https://stackoverflow.com/questions/74242584/problem-installing-tailwindcss-into-rails-7-app-windows-10-dev-environemnt

# To watch changes during dev 
yarn build --watch

# Use yarn not npm
yarn add flowbite-typography

# to run elasticsearch
elasticsearch-8.7.0-linux-x86_64/elasticsearch-8.7.0/bin$ ./elasticsearch

# elsticsearch 
sudo systemctl start elasticsearch
sudo systemctl status elasticsearch
sudo systemctl stop elasticsearch


# to reindex model 
Articles::Article.searchkick_index.delete

Articles::Article.reindex
Units::Unit.reindex
Algorithms::Algorithm.reindex
SimpleClasses::SimpleClass.reindex
Frameworks::Framework.reindex
ActsAsTaggableOn::Tag.reindex
User.reindex

# to redo slugs
Articles::ArticleVersion.find_each(&:save)

# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Alexey Sologub (c) Copyright
