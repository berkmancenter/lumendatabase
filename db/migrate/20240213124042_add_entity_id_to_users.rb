class AddEntityIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column(:users, :entity_id, :integer)
    add_index(:users, :entity_id)

    Entity.where('user_id IS NOT NULL').each do |entity|
      user = User.where(id: entity.user_id).first

      next unless user.present?

      user.entity = entity
      user.save
    end
  end
end
