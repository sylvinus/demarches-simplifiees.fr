class AttachmentsController < ApplicationController
  before_action :authenticate_logged_user!
  include ActiveStorage::SetBlob

  def show
    @attachment = @blob.attachments.find(params[:id])

    @user_can_edit = cast_bool(params[:user_can_edit])
    @direct_upload = cast_bool(params[:direct_upload])
    @view_as = params[:view_as]&.to_sym
    @auto_attach_url = params[:auto_attach_url]

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_url) }
    end
  end

  def destroy
    @attachment = @blob.attachments.find(params[:id])
    @attachment.purge_later
    flash.notice = 'La pièce jointe a bien été supprimée.'

    @champ = find_champ if params[:dossier_id]

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_url) }
    end
  end

  private

  def find_champ
    dossier = policy_scope(Dossier).includes(:champs).find(params[:dossier_id])
    dossier.champs.find_by(stable_id: params[:stable_id], row_id: params[:row_id])
  end
end
