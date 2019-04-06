# defmodule BombadilWeb.Schema do
#   use Absinthe.Schema
#   use Absinthe.Schema.Notation

#   alias Bombadil.Properties

#   object :property do
#     field :id, non_null(:id)
#     field :zpid, :string
#     field :street_address, non_null(:string)
#     field :street_address_extended, :string
#     field :locality, non_null(:string)
#     field :region, non_null(:string)
#     field :postal_code, non_null(:string)
#     field :tax_assessment, non_null(:integer)
#     field :tax_assessment_year, non_null(:integer)
#     field :tax_amount, non_null(:integer)
#     field :square_footage, non_null(:integer)
#     field :value_per_square_foot, non_null(:integer)
#   end

#   query do
#     field :property, :property do
#       arg(:id, non_null(:id))
#       resolve(fn _, %{id: id}, _ -> {:ok, Properties.get_property!(id)} end)
#     end
#   end

#   mutation do
#     field :create_property, :property do
#       arg(:input, non_null(:property_input))
#       resolve(fn _, %{input: attrs}, _ -> Properties.create_property(attrs) end)
#     end
#   end

#   input_object :property_input do
#     field :zpid, :string
#     field :street_address, non_null(:string)
#     field :street_address_extended, :string
#     field :locality, non_null(:string)
#     field :region, non_null(:string)
#     field :postal_code, non_null(:string)
#     field :tax_assessment, non_null(:integer)
#     field :tax_assessment_year, non_null(:integer)
#     field :tax_amount, non_null(:integer)
#     field :square_footage, non_null(:integer)
#     field :value_per_square_foot, non_null(:integer)
#   end
# end
