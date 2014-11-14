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