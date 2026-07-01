### Use web interface to create user and all additional resources related to user
test@test.com
123456@#%R@QT#Q#s

### new
npm install puppeteer --save

### user
asfasafsfsafsafsaasf@gmail.com
123456


testeamiladress1@gmail.com
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

## zeitwek files check
SECRET_KEY_BASE_DUMMY=1 bundle exec rails zeitwerk:check

## Erb not close tag correction
bundle exec erb_lint --format compact --autocorrect app/views/algorithm/shared/partials/algorithm_version/_algorithm_version_fields.html.erb


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





================



### user

test@test.com
123456


asfasafsfsafsafsaasf@gmail.com
123456

testeamiladress1@gmail.com
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

### postgesql
sudo systemctl start postgresql.service
sudo systemctl status postgresql.service
sudo systemctl restart postgresql


    moon@moon:/media/veracrypt1/apps2/apps/objects_space_apps/objectspaceeee/objectspace$ sudo systemctl status postgresql.service
    ● postgresql.service - PostgreSQL RDBMS
    Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
    Active: active (exited) since Tue 2026-06-16 16:52:36 +03; 2h 40min ago
    Process: 1333 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
    Main PID: 1333 (code=exited, status=0/SUCCESS)
    
    чэр 16 16:52:36 moon systemd[1]: Starting PostgreSQL RDBMS...
    чэр 16 16:52:36 moon systemd[1]: Finished PostgreSQL RDBMS.

    CREATE USER earth WITH PASSWORD 'earth';

    moon@moon:/media/veracrypt1/apps2/apps/objects_space_apps/objectspaceeee/objectspace$ sudo -u postgres psql
    psql (12.22 (Ubuntu 12.22-0ubuntu0.20.04.4))
    Type "help" for help.
    
    postgres=# CREATE USER earth WITH PASSWORD 'earth';
    CREATE ROLE
    postgres=#

    sudo -u postgres psql -c "ALTER USER earth WITH SUPERUSER;"


    moon@moon:/media/veracrypt1/apps2/apps/objects_space_apps/objectspaceeee/objectspace$ sudo -u postgres psql
    psql (12.22 (Ubuntu 12.22-0ubuntu0.20.04.4))
    Type "help" for help.
    
    postgres=# CREATE USER earth WITH PASSWORD 'earth';
    CREATE ROLE
    postgres=# \q


# install elasticsearch
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-20-04


# when setting up project
rails db:migrate
rails db:create

# creating User
test@test.com
123456

[//]: # (2.7.1 :010 > User.last)
[//]: # (User Load &#40;1.2ms&#41;  SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT $1  [["LIMIT", 1]])
[//]: # (=> #<User id: 1, email: "test@test.com", username: nil, name: nil, created_at: "2026-06-17 18:33:43.087643000 +0000", updated_at: "2026-06-17 18:33:43.087643000 +0000", tos_agreement: nil, uid: nil, avatar_url: nil, provider: nil, biography: nil, is_email_public: nil, website: nil, company: nil, location: nil>)
[//]: # (2.7.1 :011 >)


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


# objectspace

    moon@moon:/media/veracrypt1/apps2/apps/objects_space_apps/objectspaceeee/objectspace$
    moon@moon:/media/veracrypt1/apps2/apps/objects_space_apps/objectspaceeee/objectspace$ systemctl status elasticsearch.service
    ● elasticsearch.service - Elasticsearch
    Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service; disabled; vendor preset: enabled)
    Active: active (running) since Thu 2026-06-18 15:07:51 +03; 9s ago
    Docs: https://www.elastic.co
    Main PID: 95067 (java)
    Tasks: 116 (limit: 28599)
    Memory: 1.6G
    CGroup: /system.slice/elasticsearch.service
    ├─95067 /usr/share/elasticsearch/jdk/bin/java -Xms4m -Xmx64m -XX:+UseSerialGC -Dcli.name=server -Dcli.s>
    ├─95153 /usr/share/elasticsearch/jdk/bin/java -Des.networkaddress.cache.ttl=60 -Des.networkaddress.cach>
    └─95184 /usr/share/elasticsearch/modules/x-pack-ml/platform/linux-x86_64/bin/controller
    
    чэр 18 15:07:24 moon systemd[1]: Starting Elasticsearch...
    чэр 18 15:07:51 moon systemd[1]: Started Elasticsearch.
