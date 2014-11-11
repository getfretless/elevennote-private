# ElevenNote

## Getting Started

```shell
rvm install 2.1.4
rvm use 2.1.4
gem install rails --version '4.2.0.beta4'
rails _4.2.0.beta4_ new elevennote -d postgresql
cd elevennote
git init
git commit -m "Init new rails project with 4.2.0.beta4"
```

Rails 4.2 has introduced a `bin/setup` file designed to be the canonical place to add code related to getting a project setup. Let's look at it for a bit.

Run `bin/setup` to setup your database.
(It may complain that schema.rb doesn't exist yet, and that you should run `bin/rake db:migrate`. If so, run that, and run `bin/setup` again)
Run `RAILS_ENV=test bin/setup` to also setup the test database.

Add the Ruby version to the `Gemfile` and check the Rails version.
```ruby
ruby '2.1.4'
gem 'rails, '4.2.0.beta4'
```
And add a `.ruby-version` file to match.
```shell
echo '2.1.4' > .ruby-version
```
And re-navigate to the directory to make sure your Ruby switcher (RVM/Rbenv/Chruby) picks it up.
```shell
cd .
ruby --version
```

Let's fire up the server in a new tab and check it out.
```shell
bin/rails s
```

Now check out `http://localhost:3000` in a browser, and you should see a default Rails page.

Commit.
```shell
git add .
git commit -m "Specify Ruby version for this app"
```

Now that we've committed our basic, empty project, let's add a few gems that will make our lives easier. I've stripped out all comments, and added a few extra gems we want to use, so this is the entire Gemfile:

*Gemfile*
```ruby
source 'https://rubygems.org'
ruby '2.1.4'
gem 'rails', '4.2.0.beta4'
gem 'pg'
gem 'sass-rails', '~> 5.0.0.beta1'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails', '~> 4.0.0.beta2'
gem 'jbuilder', '~> 2.0'
gem 'bcrypt', '~> 3.1.7'
gem 'bootstrap-sass'
group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0.0.beta4'
  gem 'spring'
  gem 'quiet_assets'
  gem 'pry-rails'
end
gem 'rails_12factor', group: :production
```

Let's run Bundler to get these gems installed.
```shell
bundle
```
