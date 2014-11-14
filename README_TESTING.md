# TESTING

Maybe you've noticed by now, but there are a lot of things that can cause parts of your apps to not work (like, say, a stray comma or a typo).

Wouldn't it be nice if there were a way to make sure things keep working the way you expect them to?

Wouldn't it also be nice to have some idea of what is even expected to work?

I betcha Rails just might have something for that. That's right, Rails ships with a testing framework built in called `Test::Unit`. It may not be the fanciest, but it's dirt simple, and I like that.

When you are writing code that isn't particularly complicated, you probably have a pretty good idea of what you expect your code to do.
Why not write just a little bit of extra code to verify that behavior, and document your intentions.

Because of the time constraints of the class, and the exploratory nature of the cool stuff we've been showing you, we haven't been writing tests like we normally would like to, and frankly, it makes us a little sad.

But there's no way we were going to let you go without stepping you through how to test some stuff.

Because we are writing web apps that people use through a browser, we think the highest value per line of code tests you can write are "integration" tests, and ideally, they run in an environment that actually drives a web browser, like a real user will.

Let's add some gems that we like for this. Open up `Gemfile`, and inside the `:development, :test` group, add this:
```ruby
gem 'capybara'
gem 'capybara-webkit'
gem 'selenium-webdriver'
```
and run `bundle install`

[Capybara](https://github.com/jnicklas/capybara) is a Ruby interface to web browsers that can be exercised programmatically.

Let's add some stuff from Capybara's Github README (and some other stuff) to the bottom of our `test_helper` file, so that we can use it's cool stuff in our integration tests.
_test/test_helper.rb_
```ruby
require 'capybara/rails'
#... other stuff
class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  Capybara.default_driver = :webkit

  def teardown
    Capybara.reset_sessions!
  end
end
```

Since we are testing an app that deals with users and notes, we should probably have at least one user and note.

Rails ships with fixtures as the default test data strategy, so let's go with that for now. The fixtures are YAML files, and can contain ERB if necessary. They also can relate to each other. When the test suite runs, all fixtures are loaded into the database at once, so it is nice and performant when running the whole suite (though may slow things down if running tests one at a time in a large suite).

Let's create a fixture for a user and a note that belongs to that user:
_test/fixtures/users.yml_
```yaml
dave:
  name: 'David Jones'
  username: 'dave'
  password_digest: <%= BCrypt::Password.create 'password' %>
```
_test/fixtures/notes.yml_
```yaml
groceries:
  user: dave
  title: Groceries
  body_text: milk, eggs, cheese
  body_html: '<ul><li>milk</li><li>eggs</li><li>cheese</li></ul>'
```

Notice that there's a key `user: dave` in `groceries.yml`, that is a reference back to the user fixture with the top level key `dave`.

We also use `BCrypt` to make a password digest for the word `password` that we can use to log in in the test environment. We could have also just copy/pasted the digest itself, but this makes it more evident what the password actually is.

Let's create an empty test to make sure we have our environment setup correctly:
_test/integration/sessions_integration_test.rb_
```ruby
require 'test_helper'

class SessionsIntegrationTest < ActionDispatch::IntegrationTest
  test 'the truth, the whole truth, and nothing but the truth' do
    assert true
  end
end
```

if you run `bin/rake test`, or even just `bin/rake`, will run the test suite, and let us know if it worked out or not.

```shell
$ bin/rake
```

Here's a bunch of integration tests we've written to exercise this app. Let's take a look at them:
_test/integration/welcome_integration_test.rb_
```ruby
require 'test_helper'

class WelcomeIntegrationTest < ActionDispatch::IntegrationTest

  test 'The home page has the name of the app' do
    visit '/'
    assert page.has_content? 'ElevenNote'
  end

  test 'Redirects to the login page unless signed in' do
    visit '/'
    assert page.has_content? 'Sign Up for ElevenNote'
  end

end
```

_test/integration/session_integration_test.rb_
```ruby
require 'test_helper'

class SessionsIntegrationTest < ActionDispatch::IntegrationTest

  test 'Allows a guest to sign up' do
    visit '/'
    fill_in 'user_name', with: 'David Jones'
    fill_in 'user[username]', with: 'unixmonkey'
    fill_in 'user[password]', with: 'password'
    click_button 'Sign Up'
    assert page.has_content? 'Successfully signed up!'
  end

  test 'Allows an existing user to log in' do
    login users(:dave)
    assert page.has_content? 'logged in'
  end

end
```

_test/integration/notes_integration_test.rb_
```ruby
require 'test_helper'

class NotesIntegrationTest < ActionDispatch::IntegrationTest

  test 'Creating a note saves it' do
    login users(:dave)
    click_button 'New Note'
    fill_in 'note[title]', with: 'Awesome note'
    fill_in_richtext page, 'Lorem ipsum'
    click_button 'Create Note'
    assert page.has_content? 'Your note has been created'
    assert page.has_content? 'Lorem ipsum'
  end

  test 'Updating a note changes it' do
    note = notes(:groceries)
    login users(:dave)
    within('#notes') do
      find("#notes li[data-url='/notes/#{note.id}']").click
    end
    fill_in 'note[title]', with: 'Food'
    fill_in_richtext page, '<ul><li>Baloney</li></ul>'
    click_button 'Update Note'
  end

  test 'Deleting a note removes it' do
    note = notes(:groceries)
    login users(:dave)
    within('form.edit_note') do
      page.accept_confirm do
        find('i.fa-trash-o').click
      end
    end
    assert page.has_content? 'note has been deleted'
  end

end
```

Also, we've extracted some test code that needs running in more than one test file, and placed it inside `SessionsIntegrationTest` in the `test_helper.rb` file (this is the full file for those of you cut and pasting):
_test/test_helper.rb_
```ruby
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  Capybara.default_driver = :webkit
  # Capybara.default_driver = :selenium

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def login(user)
    visit '/'
    click_link 'Sign in'
    fill_in 'user[username]', with: user.username
    fill_in 'user[password]', with: 'password'
    click_button 'Sign In'
  end

  def logout
    click_link 'Logout' if page.has_content? 'Logout'
  end

  def fill_in_richtext(page, content)
    if Capybara.current_driver == :selenium
      page.execute_script "Bootsy.areas['note_body_html'].editor.setValue('#{content}');"
    else
      fill_in 'note[body_html]', with: content
    end
  end

end
```

Let's run these test and make sure they work.

```shell
$ bin/rake
```

Sometimes, it is helpful to do some debugging in our tests, but it can be hard when you can't actually see the test in progress. Capybara comes with some helpers we can drop in our code (in addition to the trusty `binding.pry`): `save_and_open_page` and `save_and_open_screenshot`. If you don't have `launchy` installed, you can just `open tmp/capybara` to preview and open the files those commands create.