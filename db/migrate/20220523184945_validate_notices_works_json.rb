class ValidateNoticesWorksJson < ActiveRecord::Migration[6.1]
  def change
    execute File.read(File.expand_path('../../../script/validate_works_json.sql', __FILE__))
    change_column_null :notices, :works_json, false
    add_check_constraint :notices, 'validate_works_json(works_json)', name: 'notices_works_json_check'
  end
end
