class SetDefaultsForJsonFields < ActiveRecord::Migration[6.1]
  def up
    change_column_default :notices, :works_json, from: nil, to: []
    change_column_default :notices, :tag_list, from: nil, to: []
    change_column_default :notices, :jurisdiction_list, from: nil, to: []
    change_column_default :notices, :regulation_list, from: nil, to: []
    change_column_default :notices, :customizations, from: nil, to: {}
  end

  def down
    change_column_default :notices, :works_json, from: [], to: nil
    change_column_default :notices, :tag_list, from: [], to: nil
    change_column_default :notices, :jurisdiction_list, from: [], to: nil
    change_column_default :notices, :regulation_list, from: [], to: nil
    change_column_default :notices, :customizations, from: {}, to: nil
  end
end
