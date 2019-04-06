defmodule BombadilWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Schema.Notation

  alias Bombadil.OpenDataBR.StreetAddresses
  alias Bombadil.Properties

  object :street_address do
    field :full_address, non_null(:string)
    field :city, non_null(:string)
    field :zip, non_null(:string)
  end

  object :savings do
    field :annual_savings, :float
    field :total_savings, :float
    field :percent_savings, :float
  end

  query do
    field :street_addresses, list_of(:street_address) do
      arg(:prefix, non_null(:string))

      resolve(fn _, %{prefix: prefix}, _ ->
        matches =
          prefix
          |> StreetAddresses.match_prefix()
          |> Enum.map(fn {full_address, city, zip} ->
            %{full_address: full_address, city: city, zip: zip}
          end)

        {:ok, matches}
      end)
    end

    field :calculate_savings, :savings do
      arg(:full_address, non_null(:string))
      arg(:city, non_null(:string))
      arg(:zip, non_null(:string))

      resolve(fn _, params, _ ->
        savings = Properties.calc_savings(params)

        {:ok,
         %{
           annual_savings: savings[:annual_savings],
           total_savings: savings[:total_savings],
           percent_savings: savings[:percent_savings]
         }}
      end)
    end
  end
end
