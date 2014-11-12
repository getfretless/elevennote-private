
## Logging in users

To let users log in, we'll first need some kind of "Sign up" form, so let's add a route and controller for registrations at `/users/new`:

_config/routes.rb_
```ruby
resources :users
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
validates :username, uniqueness: true
```

## Scoping notes to users




