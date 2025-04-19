### user
asfasafsfsafsafsaasf@gmail.com
123456


testeamiladress1@gmail.com
123456

test@test.com
123456

# work with server
lsof -i :3000
kill -QUIT PID_HERE
kill -9 PID_HERE

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
In case of this error:
ActionView::Template::Error (Failed to open TCP connection to localhost:9200 (Connection refused - connect(2) for "localhost" port 9200)):

sudo systemctl start elasticsearch
systemctl start elasticsearch
sudo systemctl status elasticsearch
sudo systemctl stop elasticsearch


# to reindex model 
Articles::Article.searchkick_index.delete

Articles::Article.reindex
Units::Unit.reindex
Algorithms::Algorithm.reindex
CheatSheets::CheatSheet.reindex
CheatSheetGroups::CheatSheetGroup.reindex
SimpleClasses::SimpleClass.reindex
Frameworks::Framework.reindex
ActsAsTaggableOn::Tag.reindex
Improvements::Improvement.reindex
User.reindex

# to redo slugs
Articles::ArticleVersion.find_each(&:save)

# sart service
systemctl start postgresql
systemctl status postgresql

# without pty
DISABLE_PRY=1 rails s

# regenerate slugs 
SimpleClasses::SimpleClassAttribute.find_each(&:save)


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


# COPYRIGHT 

Alexey Sologub (c) Copyright.
Whole project designed and developed by Alexey Sologub.
All rights to use this project belongs only to Author (Alexey Sologub) on this project.
No one under any curicamstances has right to use this project for any purpose.
You can contact Author of this project (Alexey Sologub) by his email: alexdevindeva@gmail.com
