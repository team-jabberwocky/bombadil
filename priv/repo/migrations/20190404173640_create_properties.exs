defmodule Bombadil.Repo.Migrations.CreateProperties do
  use Ecto.Migration

  def change do
    create table(:properties, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:full_address, :string, null: false)
      add(:city, :string, null: false)
      add(:zip, :string, null: false)
      add(:fire_district, :string, null: false)
      add(:school_district, :string, null: false)
      add(:design_level, :string, null: false)
      add(:market_value, :integer)
      add(:tax_assessment, :float)

      timestamps()
    end

    create unique_index(:properties, [:full_address, :city, :zip])
  end
end
