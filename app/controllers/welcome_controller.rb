class WelcomeController < ApplicationController
  def index
    if current_user.nil?
      redirect_to sign_up_path
    else
      redirect_to home_page
    end
  end

  private

  def home_page
    return Note.latest if current_user.notes.any?
    new_note_path
  end
end
