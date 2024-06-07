# frozen_string_literal: true

module ChitChat
  # Policy Summary
  class PolicySummary
    attr_reader :can_view, :can_edit, :can_delete, :can_leave, :can_add_co_organizers,
                :can_remove_co_organizers, :can_approve_applicants, :can_reject_applicants,
                :can_apply, :can_cancel

    def initialize(policy_data)
      @can_view = policy_data['can_view']
      @can_edit = policy_data['can_edit']
      @can_delete = policy_data['can_delete']
      @can_leave = policy_data['can_leave']
      @can_add_co_organizers = policy_data['can_add_co_organizers']
      @can_remove_co_organizers = policy_data['can_remove_co_organizers']
      @can_approve_applicants = policy_data['can_approve_applicants']
      @can_reject_applicants = policy_data['can_reject_applicants']
      @can_apply = policy_data['can_apply']
      @can_cancel = policy_data['can_cancel']
    end
  end
end
