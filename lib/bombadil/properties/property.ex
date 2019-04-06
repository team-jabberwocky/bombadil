defmodule Bombadil.Properties.Property do
  use Bombadil.Schema

  alias Bombadil.OpenDataBR.PropertyInformation

  @type t :: %__MODULE__{}

  schema "properties" do
    field :full_address, :string
    field :city, :string
    field :zip, :string
    field :fire_district, :string
    field :school_district, :string
    field :design_level, :string
    field :market_value, :integer
    field :tax_assessment, :float

    timestamps()
  end

  @required [:full_address, :city, :zip]

  @doc false
  @spec changeset(struct(), map()) :: Ecto.Changeset.t()
  def changeset(property, attrs) do
    property
    |> cast(attrs, @required ++ [:tax_assessment, :market_value])
    |> validate_required(@required)
    |> put_property_information()
  end

  @spec put_property_information(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp put_property_information(chset) do
    case chset do
      %Ecto.Changeset{valid?: true, changes: %{full_address: full_address, city: city, zip: zip}} ->
        case PropertyInformation.get_property_information(full_address, city, zip) do
          %{
            fire_district: fire_district,
            school_district: school_district,
            design_level: design_level
          } ->
            chset
            |> put_change(:fire_district, fire_district)
            |> put_change(:school_district, school_district)
            |> put_change(:design_level, design_level)

          _ ->
            add_error(chset, :no_property_info, "Could not find property information")
        end

      _ ->
        chset
    end
  end
end
