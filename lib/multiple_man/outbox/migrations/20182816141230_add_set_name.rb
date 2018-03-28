Sequel.migration do
  change do
    add_column :multiple_man_messages, :set_name, String, null: false
    add_index :multiple_man_messages, :set_name
  end
end
