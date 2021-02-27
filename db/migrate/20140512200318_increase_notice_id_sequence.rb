class IncreaseNoticeIdSequence < ActiveRecord::Migration[4.2]
  def up
    restart_sequence_with = (ENV['RESTART_SEQUENCE_WITH'] || 300_000_000).to_i

    ActiveRecord::Base.connection.execute(
      "ALTER SEQUENCE notices_id_seq RESTART WITH #{restart_sequence_with}"
    )
  end

  def down
    # Unsure what "down" should do, as we'd need to retain the previous sequence value permanently.
  end
end
