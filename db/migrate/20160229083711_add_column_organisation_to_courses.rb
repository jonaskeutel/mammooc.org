class AddColumnOrganisationToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :organisation, :string, null: true, default: nil
  end
end
