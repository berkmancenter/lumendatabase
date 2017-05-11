class RiskTrigger < ActiveRecord::Base
  def risky?(notice)
    if notice.submitter.try(:email) == 'google@lumendatabase.org' &&
       notice.try(:type) == 'Defamation'
      false
    else
      begin
        field_present?(notice) && condition_matches?(notice)
      rescue NoMethodError => ex
        Rails.logger.warn "Invalid risk trigger (#{id}): #{ex}"
        false
      end
    end
  end

  private

  def field_present?(notice)
    notice.send(field).present?
  end

  def condition_matches?(notice)
    if negated?
      notice.send(condition_field) != condition_value
    else
      notice.send(condition_field) == condition_value
    end
  end
end
