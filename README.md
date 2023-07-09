# 1

rails assets:precompile
rails assets:clean
./bin/dev

https://stackoverflow.com/questions/74242584/problem-installing-tailwindcss-into-rails-7-app-windows-10-dev-environemnt

# Use yarn not npm
yarn add flowbite-typography

# to run elasticsearch
elasticsearch-8.7.0-linux-x86_64/elasticsearch-8.7.0/bin$ ./elasticsearch

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