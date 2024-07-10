ActiveRecord::Schema.define(version: 2021_01_01_001) do

  create_table "data_records", force: :cascade do |t|
    t.string "name"
    t.float "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
