class WelcomeController < ApplicationController
  def index
    redirect_to(if current_user.nil? then sign_up_path else home_page end)
  end

  private

  def home_page
    if current_user.notes.any?
      note_path Note.latest
    else
      new_note_path
    end
  end
end
