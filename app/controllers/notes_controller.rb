class NotesController < ApplicationController

  before_action :load_notes

  def index
  end

  def show
    @note = Note.find params[:id]
    render :edit
  end

  def new
    @note = Note.new
    render :edit
  end

  def create
    @note = Note.new note_params
    if @note.save
      flash.now[:notice] = 'Successfully saved'
    else
      flash.now[:alert] = 'There was a problem saving that note'
    end
    render :edit
  end

  def update
    @note = Note.find params[:id]
    if @note.update note_params
      flash.now[:notice] = 'Successfully saved'
    else
      flash.now[:alert] = 'There was a problem updating that note'
    end
    render :edit
  end

  def destroy
    @note = Note.find params[:id]
    if @note.destroy
      flash.now[:notice] = 'Successfully destroyed'
    else
      flash.now[:alert] = 'There was a problem updating that note'
    end
    render :new
  end

  private

    def note_params
      params.require(:note).permit(:title, :body_text)
    end

    def load_notes
      @notes = Note.all
    end

end