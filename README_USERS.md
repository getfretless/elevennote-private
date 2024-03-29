
## Logging in users

To let users log in, we'll first need some kind of "Sign up" form, so let's add a route and controller for registrations at `/users/new`:

_config/routes.rb_
```ruby
resources :users
```
_app/views/layouts/application.html.erb_
```ruby
<header>
  <div class="well">
    ElevenNote
    <%= link_to 'Sign Up', new_user_path %>
  </div>
</header>
```
_app/controllers/users_controller.rb_
```ruby
class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, notice: t('user.flash.create.success')
    else
      flash.now[:alert] = t('user.flash.create.failure')
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
```
_config/locales/en.yml_
```yaml
...
en:
  hello: "Hello world"
  user:
    flash:
      create:
        success: "Successfully signed up!"
        failure: "There was a problem with your registration."
  note:
...
```
_app/views/users/new.html.erb_
```ruby
<h3>Sign Up for ElevenNote</h3>
<%= form_for @user do |f| %>
  <p>
    <%= f.label :name %><br>
    <%= f.text_field :name %>
  </p>
  <p>
    <%= f.label :username %><br>
    <%= f.text_field :username %>
  </p>
  <p>
    <%= f.label :password %><br>
    <%= f.password_field :password %>
  </p>
  <%= f.submit 'Sign Up' %>
<% end %>
```
_app/models/user.rb_
```ruby
validates :username, presence: true, uniqueness: true
```

We also know that we'll want to keep track of when the user is logged in or out. Typically, we call this a session. Let's make a sessions controller to log in and out. `new` for the login page, `create` for actually logging in, and `destroy` for logging out.
There's no point in showing, listing, or updating a session, so we'll leave them out of the routes:
_config/routes.rb_
```ruby
resources :sessions, only: [:new, :create, :destroy]
```
_app/controllers/sessions_controller.rb_
```ruby
class SessionsController < ApplicationController
  def new
    @user = User.new
  end
end
```
_app/views/sessions/new.html.erb_
```ruby
<h3>Sign In</h3>
<%= form_for @user, url: sessions_path do |f| %>
  <p>
    <%= f.label :username %><br>
    <%= f.text_field :username %>
  </p>
  <p>
    <%= f.label :password %><br>
    <%= f.password_field :password %>
  </p>
  <%= f.submit 'Sign In' %>
<% end %>
```

If we go to `/sessions/new`, we should see a nice login form.
When we try to submit it, it should blow up on the create action (because there is no template). However, we don't need a template, we need to check if the user exists and the password encrypts to match the encrypted_password value in our database:
__app/controllers/sessions_controller.rb_
```ruby
def create
  user = User.find_by username: user_params[:username]
  if user.present? && user.authenticate(user_params[:password])
    session[:user_id] = user.id
    redirect_to root_url, notice: t('session.flash.create.success')
  else
    @user = User.new username: user_params[:username]
    flash.now.alert = t('session.flash.create.failure')
    render :new
  end
end

private

def user_params
  params.require(:user).permit(:username, :password)
end
```
_config/locales/en.yml_
```yaml
en:
  hello: "Hello world"
  session:
    flash:
      create:
        success: "Successfully logged in!"
        failure: "There was a problem logging in with those credentials."
```

The `user.authenticate()` method is provided by `has_secure_password`. We didn't even have to write it!
The `session[:user_id] = user.id` part, is how we will keep track of the logged-in user. This is stored in an encrypted cookie, and can be read in on page load to set `current_user`.

Now we should be able to log in, however, we still can't easily tell if you are logged in or not, so let's create a method available to all our controllers:
_app/controllers/application_controller.rb_
```ruby
#...
helper_method :current_user

private

def current_user
  @current_user ||= User.find(session[:user_id]) if session[:user_id]
end
```

And a way to log out:
_config/locales/en.yml_
```yaml
destroy:
  success: "You are now logged out."
```
_app/controllers/sessions_controller.rb_
```ruby
def destroy
  session[:user_id] = nil
  redirect_to root_url, notice: t('session.flash.destroy.success')
end
```

## Restricting access to non-logged in users

Now that we have `current_user`, let's make it so that users that aren't logged in can't do very much. Let's start by making an application-wide method to keep non-logged-in users from seeing things they shouldn't.

_app/controllers/application_controller.rb_
```ruby
def authorize_user
  redirect_to new_session_path, alert: 'Not authorized' if current_user.nil?
end
```

_app/controllers/application_controller.rb_
```ruby
before_action :authorize_user, except: :index
```

Now, if we log out, the site gets a lot less interesting.
We can't access any notes, however we can log in or sign out.
Let's log back in.

## Scoping notes to users

We've created a bunch of Notes, but none of them are owned by us yet, let's change that so that they do. Open up `bin/rails console` and run this:
```ruby
user = User.last # assuming that is *your* user record
Note.update_all(user_id: user.id)
```

Look around the app. There are lots of calls like `@note = Note.find params[:id]`. We should only be able to see our own notes, and notes created by us, should have thier ownership set.

Replace instances of `Note.find` with `current_user.notes.find`, and in the `load_notes` method, only load notes `if current_user.present?`, since the `index` view is still shown to not-logged-in users.

## API authorization

## Add root api route pointing to other resources?

## Consume JSON API (HTTParty)
  Rails.application.secrets / secrets.yml


## Extract before_save to module & refactor to concern