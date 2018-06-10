# frozen_string_literal: true

module Admin
  class InvitesController < BaseController
    def index
      authorize :invite, :index?
      @invites = filtered_invites.includes(user: :account).page(params[:page])
      @invite  = Invite.new
      @bonuses = Bonu.where(:user_id => current_user.id).where("ontributor is not null").group_by(&:level)
    end

    def create
      authorize :invite, :create?

      @invite      = Invite.new(resource_params)
      @invite.user = current_user

      if @invite.save
        redirect_to admin_invites_path
      else
        @invites = Invite.page(params[:page])
        render :index
      end
    end

    def destroy
      @invite = Invite.find(params[:id])
      authorize @invite, :destroy?
      @invite.expire!
      redirect_to admin_invites_path
    end

    private

    def resource_params
      params.require(:invite).permit(:max_uses, :expires_in)
    end

    def filtered_invites
      InviteFilter.new(filter_params).results
    end

    def filter_params
      params.permit(:available, :expired)
    end
  end
end
