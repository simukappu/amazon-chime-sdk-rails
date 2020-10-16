class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room
  before_action :set_entry, only: [:destroy]

  # POST /entries
  # POST /entries.json
  def create
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to @room, notice: 'Member was successfully added.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { redirect_to @room, notice: @entry.errors }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to @room, notice: 'Member was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_room
    @room = Room.find(params[:room_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_entry
    @entry = Entry.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def entry_params
    params.require(:entry).permit(:room_id, :user_id)
  end
end
