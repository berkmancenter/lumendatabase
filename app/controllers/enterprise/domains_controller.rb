class Enterprise::DomainsController < Enterprise::BaseController
  def index
    @enterprise_account = enterprise_account
    @enterprise_domains = @enterprise_account.enterprise_domains.order(:domain)
    @domain_auto_verification_enabled = Lumen::Enterprise::DummyDataGenerator.enabled?
  end

  def create
    enterprise_domain = enterprise_account.enterprise_domains.build(enterprise_domain_params)

    if enterprise_domain.save
      if Lumen::Enterprise::DummyDataGenerator.enabled?
        Lumen::Enterprise::DummyDataGenerator
          .new(enterprise_account)
          .run(domains: [enterprise_domain.domain])

        notice = 'Domain added and auto-verified with dummy data.'
      else
        notice = 'Domain added. Add the verification file to verify ownership.'
      end

      redirect_to enterprise_domains_path, notice: notice
    else
      redirect_to(
        enterprise_domains_path,
        alert: enterprise_domain.errors.full_messages.join('<br>').html_safe
      )
    end
  end

  def verify
    enterprise_domain = find_enterprise_domain

    if enterprise_domain.verify!
      redirect_to enterprise_domains_path, notice: "#{enterprise_domain.domain} verified."
    else
      redirect_to(
        enterprise_domains_path,
        alert: "We could not verify #{enterprise_domain.domain}. Check the file and try again."
      )
    end
  end

  def destroy
    find_enterprise_domain.destroy!

    redirect_to enterprise_domains_path, notice: 'Domain removed.'
  end

  private

  def find_enterprise_domain
    enterprise_account.enterprise_domains.find(params[:id])
  end

  def enterprise_domain_params
    params.require(:enterprise_domain).permit(:domain)
  end
end
