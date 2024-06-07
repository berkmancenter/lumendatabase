class ChangeApprovedDefaultAndAllowNullInApiSubmitterRequests < ActiveRecord::Migration[7.1]
  def change
    change_column_default :api_submitter_requests, :approved, from: false, to: nil
    change_column_null :api_submitter_requests, :approved, true
  end
end
