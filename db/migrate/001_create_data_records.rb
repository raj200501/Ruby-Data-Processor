class CreateDataRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :data_records do |t|
      t.string :name
      t.float :value

      t.timestamps
    end
  end
end
