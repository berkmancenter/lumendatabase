require_relative '../page_object'

class RedactableFieldOnPage < PageObject
  def initialize(name)
    @name = name
  end

  def unredact
    page.find("#notice_#{@name}").click

    click_on 'Unredact field'
  end

  def select
    page.execute_script <<-EOS
      document.getElementById('notice_#{@name}').focus();
      document.getElementById('notice_#{@name}').select();
    EOS
  end

  def select_and_redact
    select

    click_on 'Redact selection'
  end

  def has_content?(content)
    page.find("#notice_#{@name}").value == content
  end
end
