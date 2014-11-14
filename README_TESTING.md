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