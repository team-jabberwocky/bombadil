defmodule Bombadil.Properties do
  alias Bombadil.Properties.Property
  alias Bombadil.Zillow.HTTPClient
  alias Bombadil.Repo

  @spec get_property!(id :: String.t()) :: Property.t()
  def get_property!(id), do: Repo.get!(Property, id)

  @spec create_property(map) :: {:ok, Property.t()} | {:error, Ecto.Changeset.t()}
  def create_property(attrs \\ %{}) do
    %Property{}
    |> Property.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_property(Property.t(), map) :: {:ok, Property.t()} | {:error, Ecto.Changeset.t()}
  def update_property(property, attrs \\ %{}) do
    property
    |> Property.changeset(attrs)
    |> Repo.update()
  end

  @spec calc_savings(map) :: map
  def calc_savings(attrs, years \\ 5) do
    %{market_value: market_value} =
      property =
      attrs
      |> get_or_create_property()
      |> add_zillow_data()

    tax_rate = calc_tax_rate(property)
    tax_amount = calc_tax_amount(property)

    estimated_tax_amount = market_value / 10 * tax_rate
    percent_savings = (tax_amount - estimated_tax_amount) / tax_amount
    annual_savings = tax_amount - estimated_tax_amount
    total_savings = annual_savings * years

    %{
      tax_rate: tax_rate,
      tax_amount: tax_amount,
      estimated_tax_amount: estimated_tax_amount,
      percent_savings: round(percent_savings),
      annual_savings: round(annual_savings),
      total_savings: round(total_savings),
      years: years,
      property: property
    }
  end

  @spec get_or_create_property(map) :: Property.t()
  def get_or_create_property(attrs) do
    case Repo.get_by(Property, attrs) do
      nil ->
        {:ok, property} = create_property(attrs)
        property

      property ->
        property
    end
  end

  @spec add_zillow_data(Property.t()) :: Property.t()
  def add_zillow_data(%{full_address: full_address, zip: zip} = property) do
    with {:ok, attrs} <- HTTPClient.get_property_data(full_address, zip),
         {:ok, property} <- update_property(property, attrs) do
      property
    else
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      {:error, %Ecto.Changeset{}} = error ->
        error

      _ ->
        :unknown_error
    end
  end

  @spec calc_tax_amount(Property.t()) :: float
  def calc_tax_amount(%{tax_assessment: val} = property), do: val / 10 * calc_tax_rate(property)

  @spec calc_tax_rate(Property.t()) :: float
  def calc_tax_rate(property) do
    property
    |> calc_mill_rate()
    |> Kernel./(1000)
  end

  @spec calc_mill_rate(Property.t()) :: integer
  def calc_mill_rate(%{
        fire_district: fire,
        school_district: school,
        city: city,
        design_level: design
      }) do
    [
      109.013,
      fire_mill(fire),
      school_mill(school),
      city_mill(city),
      downtown_mill(design)
    ]
    |> Enum.reduce(fn x, acc -> x + acc end)
  end

  @spec fire_mill(String.t()) :: integer
  def fire_mill(fire_disctrict) do
    case fire_disctrict do
      "ZACHARY FIRE DIST. # 1" -> 9
      "ST. GEORGE FIRE DIST. #2" -> 16
      "BROWNSFIELD FIRE DIST. #3" -> 35
      "CENTRAL FIRE DIST. #4" -> 19.25
      "EASTSIDE FIRE DIST. #5" -> 22.5
      "HOOPER ROAD FIRE DIST. #6" -> 40
      "CHANEYVILLE FIRE DISTRICT #7" -> 30
      "PRIDE FIRE DISTRICT NO. #8" -> 25
      "ALSEN FIRE DISTRICT #9" -> 15
      _ -> 0
    end
  end

  @spec school_mill(String.t()) :: float
  def school_mill(school_district) do
    cond do
      String.match?(school_district, ~r/.*BAKER.*/) -> 43.2
      String.match?(school_district, ~r/.*CENTRAL.*/) -> 57.62
      String.match?(school_district, ~r/.*ZACHARY.*/) -> 79.2
      true -> 0
    end
  end

  @spec city_mill(String.t()) :: float
  def city_mill(city) do
    case city do
      "BAKER" -> 16.82
      "BATON ROUGE" -> 10.6
      "ZACHARY" -> 5.48
      _ -> 0
    end
  end

  @spec downtown_mill(String.t()) :: integer
  def downtown_mill(design_level) do
    case design_level do
      "DOWNTOWN" -> 10
      _ -> 0
    end
  end
end
