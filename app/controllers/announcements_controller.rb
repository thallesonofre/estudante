# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :require_director!, except: [ :index ]
  before_action :set_announcement, only: [ :edit, :update, :destroy ]

  def index
    @announcements = Announcement.visible_for(current_user).includes(:author)
    @announcement = Announcement.new(priority: :normal, audience: :everyone)
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.author = current_user
    @announcement.published_at = Time.current

    if @announcement.save
      redirect_to announcements_path, notice: "Comunicado publicado no mural da escola!"
    else
      @announcements = Announcement.visible_for(current_user).includes(:author)
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @announcement.update(announcement_params)
      redirect_to announcements_path, notice: "Comunicado atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @announcement.destroy!
    redirect_to announcements_path, notice: "Comunicado removido do mural."
  end

  private

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def announcement_params
    params.require(:announcement).permit(:title, :content, :priority, :audience, :pinned)
  end
end
