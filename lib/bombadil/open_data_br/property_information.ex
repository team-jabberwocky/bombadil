defmodule Bombadil.OpenDataBR.PropertyInformation do
  use GenServer

  alias NimbleCSV.RFC4180, as: CSV

  ## Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  def get_property_information(full_address, city, zip) do
    GenServer.call(__MODULE__, {:get_property_information, {full_address, city, zip}}, 10_000)
  end

  ## Server

  @impl true
  def init(:ok) do
    Process.send(self(), :initialize_cache, [])
    {:ok, []}
  end

  @impl true
  def handle_call({:get_property_information, key}, _from, state) do
    result =
      case :ets.lookup(:property_information, key) do
        [{_, {fire_district, school_district, design_level}}] ->
          %{
            fire_district: fire_district,
            school_district: school_district,
            design_level: design_level
          }

        _ ->
          :not_found
      end

    {:reply, result, state}
  end

  @impl true
  def handle_info(:initialize_cache, state) do
    :ets.new(:property_information, [:public, :named_table])

    "priv/property_information.csv"
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.each(fn [
                      _address_point_id,
                      _lot_id,
                      _address_id,
                      _address_no,
                      _street_prefix_direction,
                      _street_prefix_type,
                      _street_name,
                      _street_suffix_type,
                      _street_suffix_direction,
                      _street_extension,
                      full_address,
                      city,
                      zip,
                      _subdivision_id,
                      _subdivision,
                      _property_name,
                      _business_id,
                      _business_name,
                      _business_naics_code,
                      _planning_district_no,
                      _subarea_no,
                      _lot_block_map_no,
                      _lot_no,
                      _city_block_square_no,
                      _lot_jurisdiction,
                      _ward_no,
                      _tax_section,
                      _public_land_survey_system,
                      _census_tract,
                      _census_block_group,
                      _traffic_analysis_zone,
                      _police_district,
                      fire_district,
                      school_district,
                      _voting_precinct,
                      _council_district_no,
                      _enterprise_zone,
                      _economic_development_zone,
                      _redevelopment_district,
                      _historic_district,
                      _historic_landmark,
                      _urban_design_district,
                      _urban_design_overlay_district,
                      _industrial_area,
                      _existing_land_use,
                      _future_land_use,
                      design_level,
                      _zoning_type,
                      _lot_area_measurement,
                      _geolocation
                    ] ->
      key = {full_address, city, zip}

      val = {
        String.upcase(fire_district),
        String.upcase(school_district),
        String.upcase(design_level)
      }

      :ets.insert(:property_information, {key, val})
    end)

    {:noreply, state}
  end
end
