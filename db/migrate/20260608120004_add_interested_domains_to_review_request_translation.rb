class AddInterestedDomainsToReviewRequestTranslation < ActiveRecord::Migration[7.2]
  # Surface the applicant's "domains they want to watch" in the admin review
  # request email. Updates the existing review-request bodies in place (rather
  # than editing the original create migration, which has already run).
  NEW_BODIES = {
    'enterprise_email_admin_review_request_text' => <<~TEXT,
      A new Lumen Enterprise registration was submitted and is waiting for review.

      Company name: %{company_name}
      Applicant email: %{applicant_email}

      Domains they want to watch:
      %{interested_domains}

      Company contact information:
      %{company_contact_information}

      Representative contact information:
      %{representative_contact_information}

      Review, accept, or reject it here:
      %{admin_url}
    TEXT
    'enterprise_email_admin_review_request_html' => <<~HTML
      <h1>New Lumen Enterprise registration to review</h1>

      <table>
        <tr><th align="left">Company name</th><td>%{company_name}</td></tr>
        <tr><th align="left">Applicant email</th><td>%{applicant_email}</td></tr>
      </table>

      <h2>Domains they want to watch</h2>
      %{interested_domains}

      <h2>Company contact information</h2>
      %{company_contact_information}

      <h2>Representative contact information</h2>
      %{representative_contact_information}

      <p><a href="%{admin_url}">Review, accept, or reject this registration</a></p>
    HTML
  }.freeze

  OLD_BODIES = {
    'enterprise_email_admin_review_request_text' => <<~TEXT,
      A new Lumen Enterprise registration was submitted and is waiting for review.

      Company name: %{company_name}
      Applicant email: %{applicant_email}

      Company contact information:
      %{company_contact_information}

      Representative contact information:
      %{representative_contact_information}

      Review, accept, or reject it here:
      %{admin_url}
    TEXT
    'enterprise_email_admin_review_request_html' => <<~HTML
      <h1>New Lumen Enterprise registration to review</h1>

      <table>
        <tr><th align="left">Company name</th><td>%{company_name}</td></tr>
        <tr><th align="left">Applicant email</th><td>%{applicant_email}</td></tr>
      </table>

      <h2>Company contact information</h2>
      %{company_contact_information}

      <h2>Representative contact information</h2>
      %{representative_contact_information}

      <p><a href="%{admin_url}">Review, accept, or reject this registration</a></p>
    HTML
  }.freeze

  def up
    apply_bodies(NEW_BODIES)
  end

  def down
    apply_bodies(OLD_BODIES)
  end

  private

  def apply_bodies(bodies)
    bodies.each do |key, body|
      Translation.find_by(key: key)&.update!(body: body)
    end
  end
end
