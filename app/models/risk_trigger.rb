class RiskTrigger < ActiveRecord::Base

  def risky?(notice)
    field_present?(notice) && condition_matches?(notice) unless notice.submitter.try(:email, "google@chillingeffects.org") && notice.try(:type, "Defamation")

  rescue NoMethodError => ex
    Rails.logger.warn "Invalid risk trigger (#{id}): #{ex}"

    false
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
