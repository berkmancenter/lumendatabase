class Enterprise::DomainsController < Enterprise::BaseController
  def create
    enterprise_domain = enterprise_account.enterprise_domains.build(enterprise_domain_params)

    if enterprise_domain.save
      redirect_to enterprise_settings_path, notice: 'Domain added. Add the verification file to verify ownership.'
    else
      redirect_to(
        enterprise_settings_path,
        alert: enterprise_domain.errors.full_messages.join('<br>').html_safe
      )
    end
  end

  def verify
    enterprise_domain = find_enterprise_domain

    if enterprise_domain.verify!
      redirect_to enterprise_settings_path, notice: "#{enterprise_domain.domain} verified."
    else
      redirect_to(
        enterprise_settings_path,
        alert: "We could not verify #{enterprise_domain.domain}. Check the file and try again."
      )
    end
  end

  def destroy
    find_enterprise_domain.destroy!

    redirect_to enterprise_settings_path, notice: 'Domain removed.'
  end

  private

  def find_enterprise_domain
    enterprise_account.enterprise_domains.find(params[:id])
  end

  def enterprise_domain_params
    params.require(:enterprise_domain).permit(:domain)
  end
end
