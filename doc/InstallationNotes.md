Installation (Aq2, MacOS)
============

Install script: `scripts/install.sh`

`rake init:initialize[name,login,password,admin]`

Requirements
---
### Ruby & rbenv
Update your homebrew

    brew update
    
Install rbenv and ruby-build

    brew install rbenv
    brew install ruby-build
    
Update your .bash_profile

    eval "$(rbenv init -)"

Next move to your current aquarium directory. Install the version of ruby indicated by aquarium/.ruby-version

    cd path/to/aquarium
    rbenv local install
    rbenv rehash

Alternatively, you can view and install a specific version of ruby by

    rbenv install -list
    rbenv local install p2.0.0

### Node, npm, & bower
Install node and npm

    brew install node
    
Verify installation

    node -v
    npm -v
    
Install bower

    npm install -g bower

Configuring aquarium
---

Go to aquarium/config/initializers and do

	cd config/initializers
	cp aquarium_template.notrb aquarium.rb
	
Go to aquarium/config and do

	cd ..
	cp database_template.yml database.yml

You may edit the database.yml to configure your particular database

For development with sqlit3, add the following to your gem file

    cd ..
    echo 'gem "sqlite3"' >> GemFile
    echo 'gem "test-unit"' >> GemFile

To install sqlite3 and mysql on mac

    brew install sqlite3
    brew install mysql

Install mysql: https://gist.github.com/nrollr/a8d156206fa1e53c6cd6. You may need to install Xcode command tools if you
are getting weird errors. Run:

    xcode-select --install
    gem install mysql2

Install bundler

    gem install bundler

Install mysql gem

    gem install mysql

You can install all the gems

	bundle install

Install packages

    bower install

For development mode using sqlite3, comment out the following in _aquarium/config/environments/development.rb_

    #Paperclip=>S3
    #config.paperclip_defaults={
    #storage::s3,
    #s3_host_name:"s3-#{ENV['AWS_REGION']}.amazonaws.com",
    #s3_permissions::private,
    #s3_credentials:{
    #bucket:ENV.fetch('S3_BUCKET_NAME'),
    #access_key_id:ENV.fetch('AWS_ACCESS_KEY_ID'),
    #secret_access_key:ENV.fetch('AWS_SECRET_ACCESS_KEY'),
    #s3_region:ENV.fetch('AWS_REGION')
    #}
    #}
    
Go to _aquarium/script/rails_ and change the following to the ruby version designated in .ruby-versions

    #!/usr/bin/env ruby-2.2.0p0
    ...


Initialization
---
Initialize the sqlite3 database

    RAILS_ENV=development rake db:schema:load

Begin the rails server

    RAILS_ENV=development rails s

Go to 0.0.0.0:3000 in your browser to see the login page.

#### Initializing krill server

Open another terminal, move to the aquarium directory and begin the krill server
    
    cd path/to/aquarium
    rails runner "Krill::Server.new.run(3500)"

#### Initializing the user, groups, and budgets

Initialize the first user by opening a rails counsel:

    RAILS_ENV=production rails c
    load 'script/init.rb'
    make_user "Your Name", "your login", "your password", admin: true

Go to 0.0.0.0:3000 and login with account

If you do not have admin access, you may need to manually create a new membership.

    m = Membership.new
    m.group_id = Group.find_by_name('admin').id
    m.user_id = User.first.id
    m.save

    
      technician_group = Group.new
      technician_group.name = 'technicians'
      technician_group.description = "A group containing technicians"
      technician_group.save



Go to "Groups" and create group "technicians"

Create a budget

In one strange error involving homebrew and rails counsel, I had to run the following

    ln -s /usr/local/opt/readline/lib/libreadline.7.0.dylib /usr/local/opt/readline/lib/libreadline.6.dylib

#### Killing the server server

List all servers running on port 3000

    lsof -wni tcp:3000
    
Find PID of ruby server and kill server

    kill -9 PID

Beyond...
---

* initialize with permanent host and database (mysql)
* mirroring a production server