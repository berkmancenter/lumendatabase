class Role < ActiveRecord::Base
  NAMES = %w(
    submitter
    redactor
    publisher
    admin
    super_admin
    researcher
  )

  NAMES.each do |name|
    # Define a lazy, class-level reader for each role we support. This
    # allows us to use Role.redactor to find-or-create that role.
    define_singleton_method(name) do
      where(name: name).first || create(name: name)
    end
  end

  def self.default
    redactor
  end

end
