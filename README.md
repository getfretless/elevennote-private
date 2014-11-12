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
gem 'rails', '4.2.0.beta4'
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

In order to actually use Bootstrap's styles, we'll need to include its stylesheets in app/assets/stylesheets/application.css.

Add a new stylesheet file named:
*app/assets/stylesheets/structure.css.scss*
```ruby
@import 'bootstrap-sprockets';
@import 'bootstrap';
```

I kind of like keeping `application.css` as nothing more than a manifest for requiring other stylesheets, which it already does automatically because of this line:
```css
 *= require_tree .
```

Which requires all other stylesheets (alphabetically) and compliles them down to a single `application.css` in production.

If you need special order for your stylesheets, then you might want to remove the `require_tree .` line, and require structure explicity like so:
```css
 *= require 'structure'
```

Let's review our changes and make another commit.
```shell
git commit -m "Add bootstrap-sass"
```

Let's add another gem to use [Font-Awesome](http://fortawesome.github.io/Font-Awesome) in our project, for some fancy icons.

Add a new gem to the `Gemfile` and run `bundle`:
```ruby
gem 'font-awesome-sass'
```

Then add a new stylesheet to use it. I'm calling it `fonts.css.scss`:
```css
@import "font-awesome-sprockets";
@import "font-awesome";
@import url(http://fonts.googleapis.com/css?family=Merriweather:400,300,300italic|Oxygen:400,300,700);
```

Commit.

# `User` model

We will not be using Devise in this app. We're going to roll our own authentication system.

Create a `User` model, inheriting from `ActiveRecord::Base`.

## [`has_secure_password`](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password)
Rails, since version 3.1, includes a method called `has_secure_password` that makes rolling our own authentication easier.

```ruby
class User < ActiveRecord::Base
  has_secure_password
end
```

`has_secure_password` does several interesting things. It adds `password` and `password_confirmation` methods to your model, but only _stores_ a bcrypt-encrypted password to the database

It automatically adds validations to check for the presence of `password` and a matching `password_confirmation` value—neither of which is saved to the database unencrypted—upon creating a new record. It also adds an `authenticate` method.

All `has_secure_password` requires is that your database table have a column called `password_digest`.

## Lab: `create_users` migration

Generate a `create_users` migration now. Include the following columns, all strings:

* `username`
* `name`
* `password_digest`

Also include timestamp columns.

## Solution

```shell
bin/rails g migration create_users
```

```ruby
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :password_digest
      t.timestamps
    end
  end
end
```

```ruby
class User < ActiveRecord::Base
  has_secure_password
end
```

## Extra

Add a validation to make sure the password is at least 8 characters.

```ruby
class User < ActiveRecord::Base
  has_secure_password
  validates :password, length: { minimum: 8 }
end
```

## Create the `users` table.

Migrate the database to create the new table.

```shell
bin/rake db:migrate
```

## Test `User` in the console.

Let's try creating a user with just a user name.

```ruby
[1] pry(main)> user = User.new
=> #<User id: nil, username: nil, name: nil, password_digest: nil, created_at: nil, updated_at: nil>
[2] pry(main)> user.username = "prezbiz"
=> "prezbiz"
[3] pry(main)> user.save
   (0.2ms)  BEGIN
   (0.2ms)  ROLLBACK
=> false
[4] pry(main)> user.errors.messages
=> {:password=>["can't be blank", "is too short (minimum is 8 characters)"]}
```

It fails, as `password` is blank. It's also too short, naturally. Let's set a password and try again.

```ruby
[5] pry(main)> user.password = "abc12345"
=> "abc12345"
[6] pry(main)> user.save
   (0.1ms)  BEGIN
  SQL (0.4ms)  INSERT INTO "users" ("created_at", "password_digest", "updated_at", "username") VALUES ($1, $2, $3, $4) RETURNING "id"  [["created_at", "2014-11-09 19:24:39.810016"], ["password_digest", "$2a$10$VE9UwwRzhEG/i3o1RSPMAenPvwcqcb28M/wXz1Hh/Kro2MG3WjDUm"], ["updated_at", "2014-11-09 19:24:39.810016"], ["username", "prezbiz"]]
   (6.6ms)  COMMIT
=> true
[7] pry(main)> user.password_digest
=> "$2a$10$VE9UwwRzhEG/i3o1RSPMAenPvwcqcb28M/wXz1Hh/Kro2MG3WjDUm"
```

That works, and it stores the encrypted password in the database.

By default, `has_secure_password` does not require that you re-enter the password into `password_confirmation`. But if you _do_ have a value for `password_confirmation`, it must match `password`.

```ruby
[8] pry(main)> ironman = User.new username: 'tstark', password: 'iamhandsome', password_confirmation: 'sosohandsome'

=> #<User id: nil, username: "tstark", name: nil, password_digest: "$2a$10$QxLAzJ.13yB82ouGQNU8XudufRHj1MvuYyuHhlc7Ucd...", created_at: nil, updated_at: nil>
[9] pry(main)> ironman.save
   (0.1ms)  BEGIN
   (0.1ms)  ROLLBACK
=> false
[10] pry(main)> ironman.errors.messages
=> {:password_confirmation=>["doesn't match Password"]}
```

Make the two fields match, and it works.

```ruby
[11] pry(main)> captain = User.new username: "srogers", password: "MURRRICA!!!", password_confirmation: "MURRRICA!!!"

=> #<User id: nil, username: "srogers", name: nil, password_digest: "$2a$10$Kh18B4cbsjpUCPAMyWF53eHDNuakFJBQeVtlEKhGre2...", created_at: nil, updated_at: nil>
[12] pry(main)> captain.save
   (0.1ms)  BEGIN
  SQL (0.2ms)  INSERT INTO "users" ("created_at", "password_digest", "updated_at", "username") VALUES ($1, $2, $3, $4) RETURNING "id"  [["created_at", "2014-11-09 19:42:40.079761"], ["password_digest", "$2a$10$Kh18B4cbsjpUCPAMyWF53eHDNuakFJBQeVtlEKhGre2GOsJuRgWQe"], ["updated_at", "2014-11-09 19:42:40.079761"], ["username", "srogers"]]
   (6.6ms)  COMMIT
=> true
```

Let's commit this:
```shell
git commit -m "Add User model and use has_secure_password"
```

# `Note` model

## Lab: `Note` model
Create a `Note` model.

A note should have the following fields:
* `title`
* 'body_html'
* 'body_text'
* `user_id`, with an index
* timestamp fields

Create a model, complete with database table, for `Note`. When you are finished, you should be able to do the following from the console:

```ruby
[1] pry(main)> ironman = User.create username: 'tstark', password: 'iamhandsome', password_confirmation: 'iamhandsome'
[2] pry(main)> note = Note.new title: "Groceries", body_text: "Cookies and ice cream", body_html: "<ul><li>Cookies</li><li>ice cream</li></ul>"
[3] pry(main)> note.user = ironman
[4] pry(main)> note.save
[5] pry(main)> ironman.notes
```

If everything is set up correctly, the last statement should return something like this:

```ruby
=> [#<Note id: 1, title: "Groceries", body_html: "<ul><li>Cookies</li><li>ice cream</li></ul>", body_text: "Cookies and ice cream", user_id: 1, created_at: "2014-11-09 20:06:58", updated_at: "2014-11-09 20:06:58">]
```

## Solution

_app/models/note.rb_
```ruby
class Note < ActiveRecord::Base
  belongs_to :user
end
```

_app/models/user.rb_
```ruby
class User < ActiveRecord::Base
  has_secure_password
  has_many :notes
  validates :password, length: { :minimum => 8 }
end
```

```shell
bin/rails g migration create_notes
```

```ruby
class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :title
      t.string :body_html
      t.string :body_text
      t.references :user, index:true
      t.timestamps
    end
  end
end
```

```shell
bin/rake db:migrate
```

Commit.

```shell
git commit -m "Add notes"
```
## Add CSS

Let's add another named `style.css.scss`:
```css
.container {
  width: 100% !important;
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.row {
  margin-left: 0 !important;
  margin-right: 0 !important;
}

.col-xs-12 {
  padding-left: 0 !important;
  padding-right: 0 !important;
}
```

## Install Bootsy WYSIWYG Editor

```ruby
gem 'bootsy'
```

```shell
rails generate bootsy:install
rake bootsy:install:migrations
rake db:migrate
```

Replace the `text_area` with `bootsy_area`.

_app/views/notes/_form.html.erb_
```erb
<%= f.bootsy_area :body_html, editor_options: { image: false, html: true } %>
```

## turbolinks

Explain clash between turbolinks and bootsy.

## Using Locales

_config/locales/en.yml_
```yaml
en:
  hello: "Hello world"
  note:
    flash:
      create:
        success: "Your note has been created!"
        failure: "There was a problem creating your note."
      update:
        success: "Saved!"
        failure: "There was a problem saving your changes."
      destroy:
        success: "That note has been deleted."
        failure: "We weren't able to delete that note."
```

Example usage:
```ruby
flash.now[:notice] = t("note.flash.create.success")
```

We can set all our flash messages in a private method in our controller.

_app/controllers/notes_controller.rb_
```ruby
def set_flash_for(action_result)
  if action_result
    flash[:notice] = t("note.flash.#{action_name}.success")
  else
    flash.now[:alert] = t("note.flash.#{action_name}.failure")
  end
end
```

We can call this method from our controller actions as follows:

_app/controllers/notes_controller.rb_
```ruby
def create
  @note = Note.new note_params
  set_flash_for @note.save
  redirect_to new_note_path
end
```

We still only want to redirect in the event that there are no errors when saving. We can use another private method to make that determination.

```ruby
def render_or_redirect
  if @note.errors.any?
    render :edit
  else
    redirect_to @note
  end
end
```

And we'll again call that in our actions (`create` and `update` only, in this case.):

```ruby
  def create
    @note = Note.new note_params
    set_flash_for @note.save
    render_or_redirect
  end
```

## JSON API

We want to be able to get at our notes programmatically, say, through a mobile app, or to integrate with someone else's app. Rails gives you all the pieces you need to do that with a minimum of pain.

Because Rails encourages use of a RESTful pattern for resource-based controllers with standardized CRUD actions, it makes it easy to accept & return JSON, or even XML.

If you take a look back at the scaffolded `chirps_controller.rb` in [ElevenPeeps](http://github.com/getfretless/elevenpeeps), you'll notice that each of the RESTful actions has a `respond_to` block and some have `.json.jbuilder` views. If we were to make requests to say, [http://localhost:3000/chirps.json](http://localhost:3000/chirps.json), you should see a JSON response in your browser.

If viewing JSON with your web browser is something you do often, try installing [JSON Formatter](https://chrome.google.com/webstore/detail/bcjindcccaagfpapjjmafapmmgkkhgoa) if you are using Chrome for your web browser.

Let's take a look at the source in elevenpeeps for a minute to see what it is doing.

This is pretty great, but if you need to have standardized interfaces for 3rd-party integrations, then it is best to not have API code intermixed with our web application code.

Let's add a new controller for the api, and since we want this to have a similar RESTful structure as the rest of our app, let's namespace it under `/api`, so `/api/notes.json` is a different action than the normal route `notes#index`.

Additionally, let's namespace it under a version number, so if we have to change this API in the future, we don't break backwards compatibility with clients that have done integrations against your older versions of the API.

Create a new route in `config/routes.rb`:
```ruby
namespace :api do
  namespace :v1 do
    resources :notes
  end
end
```

And add the necessary folders and files to get a file at `app/controllers/api/v1/notes_controller.rb` with a basic `index` action that responds to `.json`:
```ruby
class API::V1::NotesController < ApplicationController
  def index
    @notes = Note.all
    respond_to do |format|
      format.json do
        render json: @notes.to_json
      end
    end
  end
end
```

The `to_json` method can be called on any ActiveRecord model or relation, and we just called it on a relation, to return a collection of JSON hashes inside an array.

This will also allow you to get a response from `/api/v1/notes` in addtion to `/api/v1/notes.json`.

However, because this is an API that we don't want to change, this is not a good thing to do.

Because of the `@notes.to_json` conversion that is happening, will take all column names and render them out in the response JSON objects. What if we added a migration to add, remove, or rename a column? Then the JSON output could change, which may break applications that are consuming that API.

Rails now ships by default with a gem named `jbuilder`, which makes it easier to map Ruby objects to thier JSON representation in a way, that even if we update the model, the JSON "views" won't change.

Let's add a `jbuilder` view for `api/v1#index` in `app/views/api/v1/notes/index.json.jbuilder`:
```ruby
json.array!(@notes) do |note|
  json.extract! note, :id, :title, :body_text, :body_html, :created_at, :updated_at
  json.url api_v1_note_url(note, format: :json)
end
```

Note the `json.extract!` takes the `note` object, and an array of symbols that correspond to the columns we want to display. If those columns do change, then the json may not have a value for that anymore, but it will still include the JSON key in the response with that name.

Also note the custom attribute `json.url` that I set up to link to the `_url` path for this object. This is a technique used for "disoverable" API's (sometimes called HyperMedia). This lets an API consumer load some data, and have it apparent of where you can go to get more information.

Now that the view is in place, we can remove the `render json: @notes.to_json` block to look like this:
```ruby
def index
  @notes = Note.all
  respond_to do |format|
    format.json
  end
end
```

or the shorter:
```ruby
def index
  @notes = Note.all
  respond_to :json
end
```

And our JSON should look really nice.

LAB: Like the `index` method, make a `show` method for the `api/v1/notes_controller` with a reasonable `.jbuilder` template.

SOLUTION:
_app/controllers/api/v1/notes_controller.rb_
```ruby
class API::V1::NotesController < ApplicationController

  def index
    @notes = Note.all
    respond_to :json
  end

  def show
    @note = Note.find params[:id]
    respond_to :json
  end

end
```

_app/views/api/v1/notes/show.json.jbuilder_
```ruby
json.extract! @note, :id, :title, :body_text, :body_html, :created_at, :updated_at
```

We can save ourselves from typing `respond_to :json` in every single action (since this is a JSON API...) by setting the default to 'json' like this:
```ruby
namespace :api, defaults: { format: 'json' } do
  namespace :v1 do
    resources :notes
  end
end
```

And now you can remove all `respond_to :json` calls in the api controllers.
