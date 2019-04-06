defmodule Bombadil.Zillow.Client do
  @moduledoc """
  This module defines an explicit contract to which all modules that act as
  consumers of the Zillow API service should adhere to.
  """

  @doc """
  Gets property data via the GetDeepSearchResults endpoint.
  """
  @callback get_property_data(full_address :: String.t(), zip :: String.t()) ::
              {:ok, term} | {:error, term}
end
