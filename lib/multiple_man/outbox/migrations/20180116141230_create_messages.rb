Sequel.migration do
  change do
    create_table :multiple_man_messages do
      primary_key :id, 'BIGSERIAL'
      column :routing_key, String, null: false
      column :payload, String, null: false

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :id
    end
  end
end
