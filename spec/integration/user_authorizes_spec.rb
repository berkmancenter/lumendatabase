require 'rails_helper'
require 'support/contain_link'

feature "User authorization" do
  include ContainLink

  scenario "A non logged-in user is redirected to sign in" do
    user = AdminOnPage.new(create(:user))

    user.visit_admin

    expect(page).to have_text("You are not authorized to access this page.")
  end

  scenario "Submitters- cannot access admin" do
    page_objects = [
      AdminOnPage.new(create(:user)),
      AdminOnPage.new(create(:user, :submitter))
    ]

    page_objects.each do |obj|
      obj.sign_into_admin

      expect(obj).to be_denied_access
    end
  end

  scenario "Redactors+ are able to access admin" do
    page_objects = [
      AdminOnPage.new(create(:user, :redactor)),
      AdminOnPage.new(create(:user, :publisher)),
      AdminOnPage.new(create(:user, :admin)),
      AdminOnPage.new(create(:user, :super_admin))
    ]

    page_objects.each do |obj|
      obj.sign_into_admin

      expect(obj).to be_in_admin
    end
  end

  scenario "All levels can edit notices" do
    notice = create(:dmca)
    page_objects = [
      AdminOnPage.new(create(:user, :redactor)),
      AdminOnPage.new(create(:user, :publisher)),
      AdminOnPage.new(create(:user, :admin)),
      AdminOnPage.new(create(:user, :super_admin))
    ]

    page_objects.each_with_index do |obj, idx|
      obj.sign_in_and_edit(notice, Title: "New title #{idx}")

      expect(notice.reload.title).to eq "New title #{idx}"
    end
  end

  scenario "Redactors cannot publish (admin)" do
    page_object = AdminOnPage.new(create(:user, :redactor))
    notice = create(:dmca, review_required: true)

    page_object.sign_in_and_edit(notice)

    expect(page).to have_no_css('input#notice_review_required')
  end

  scenario "Publishers+ can publish (admin)" do
    notice = create(:dmca, review_required: true)
    page_objects = [
      AdminOnPage.new(create(:user, :publisher)),
      AdminOnPage.new(create(:user, :admin)),
      AdminOnPage.new(create(:user, :super_admin))
    ]

    page_objects.each do |obj|
      obj.sign_in_and_edit(notice)

      expect(page).to have_css('input#notice_review_required')
    end
  end

  scenario "Redactors cannot publish (redact tool)" do
    notice = create(:dmca, review_required: true)
    page_object = AdminOnPage.new(create(:user, :redactor))

    page_object.sign_in_and_redact(notice)

    expect(page).to have_no_css('input#notice_review_required')
  end

  scenario "Publishers+ can publish (redact tool)" do
    notice = create(:dmca, review_required: true)
    page_objects = [
      AdminOnPage.new(create(:user, :publisher)),
      AdminOnPage.new(create(:user, :admin)),
      AdminOnPage.new(create(:user, :super_admin))
    ]

    page_objects.each do |obj|
      obj.sign_in_and_redact(notice)

      expect(page).to have_css('input#notice_review_required')
    end
  end

  scenario "Redactors and Publishers cannot create/delete notices" do
    notice = create(:dmca)
    page_objects = [
      AdminOnPage.new(create(:user, :redactor)),
      AdminOnPage.new(create(:user, :publisher))
    ]

    page_objects.each do |obj|
      obj.sign_in_and_create(Notice)

      expect(obj).to be_denied_access

      obj.delete(notice)

      expect(obj).to be_denied_access
    end
  end

  scenario "Redactors and Publishers cannot edit site data" do
    site_data = [
      create(:topic),
      create(:relevant_question),
      create(:blog_entry),
      create(:user),
      create(:role)
    ]
    page_objects = [
      AdminOnPage.new(create(:user, :redactor)),
      AdminOnPage.new(create(:user, :publisher))
    ]

    page_objects.each do |obj|
      sign_in obj.user

      site_data.each do |resource|
        obj.edit(resource)

        expect(obj).to be_denied_access
      end
    end
  end

  scenario "Redactors and Publishers cannot rescind notices" do
    notice = create(:dmca)
    page_objects = [
      AdminOnPage.new(create(:user, :redactor)),
      AdminOnPage.new(create(:user, :publisher))
    ]

    page_objects.each do |obj|
      obj.sign_in_and_edit(notice)

      expect(page).to have_no_css('input#notice_rescinded')
    end
  end

  scenario "Admins and Super admins can edit site data" do
    topic = create(:topic)
    page_objects = [
      AdminOnPage.new(create(:user, :admin)),
      AdminOnPage.new(create(:user, :super_admin))
    ]

    page_objects.each_with_index do |obj, idx|
      obj.sign_in_and_edit(topic, Name: "New name #{idx}")

      expect(topic.reload.name).to eq "New name #{idx}"
    end
  end

  scenario "Admins and Super admins can rescind notices" do
    notice = create(:dmca)
    page_objects = [
      AdminOnPage.new(create(:user, :admin)),
      AdminOnPage.new(create(:user, :super_admin))
    ]

    page_objects.each do |obj|
      obj.sign_in_and_edit(notice)

      expect(page).to have_css('input#notice_rescinded')
    end
  end

  scenario "Admins cannot edit Users or Access levels" do
    site_data = [
      create(:user),
      create(:role)
    ]
    obj = AdminOnPage.new(create(:user, :admin))
    sign_in obj.user

    site_data.each do |resource|
      obj.edit(resource)

      expect(obj).to be_denied_access
    end
  end

  scenario "Super admins can edit other Users" do
    obj = AdminOnPage.new(create(:user, :super_admin))
    other_user = create(:user)

    obj.sign_in_and_edit(other_user, user_email: "new-email@example.com")

    expect(other_user.reload.email).to eq "new-email@example.com"
  end

  scenario "Super admins can edit Roles" do
    obj = AdminOnPage.new(create(:user, :super_admin))
    role = create(:role, name: "some_name")

    obj.sign_in_and_edit(role, Name: "another_name")

    expect(role.reload.name).to eq "another_name"
  end

  scenario "Visibility of notice administation links" do
    notice = create(:dmca)
    admin_path = rails_admin.show_path(model_name: 'dmca', id: notice.id)

    visit notice_path(notice)

    expect(page).not_to contain_link(admin_path)

    obj = AdminOnPage.new(create(:user, :admin))
    sign_in obj.user

    visit notice_path(notice)

    expect(page).to contain_link(admin_path)

    click_on "Edit in Admin"

    expect(obj).to be_in_admin
  end
end
