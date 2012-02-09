class CreateAssignees < ActiveRecord::Migration
  def change
    create_table :assignees do |t|
      t.integer :card_id, :user_id
      t.timestamps
    end
  end
end
