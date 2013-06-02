class WordsController < ApplicationController
  
  def index
    @words = Word.all
  end
  
  def destroy
    word = Word.find(params[:id])
    @id = params[:id]
    word.destroy
  end
  
  def new
    @word = Word.new
  end
  
  def create
    word = Word.new(params[:word])
    if word.save!
      redirect_to words_path, :notice => "Added new word"     
    else
      flash.now[:error] = "Error adding word"
      render 'new'
    end
  end
  
  def edit
    @word = Word.find(params[:id])  
  end
  
  def update
    @word = Word.find(params[:id])
    if @word.update_attributes(params[:word])
      flash.now[:success] = "Updated word"
    else
      flash.now[:error] = "Error updating word"
    end
    render 'edit'
  end
end
