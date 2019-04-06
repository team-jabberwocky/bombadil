defmodule Bombadil.Zillow.HTTPClient do
  import SweetXml

  @api_url "http://www.zillow.com/webservice"

  @behaviour Bombadil.Zillow.Client

  @impl true
  def get_property_data(full_address, zip) do
    endpoint = "/GetDeepSearchResults.htm"

    query =
      %{"zws-id": System.get_env("ZWS_ID"), address: full_address, citystatezip: zip}
      |> URI.encode_query()

    case HTTPoison.get(@api_url <> endpoint <> "?" <> query) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parse_property_data(body)}

      {:ok, %HTTPoison.Response{status_code: _, body: body}} ->
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp parse_property_data(doc) do
    data =
      doc
      |> xpath(~x"//SearchResults:searchresults/response/results/result")
      |> xmap(
        tax_assessment: ~x"./taxAssessment/text()",
        market_value: ~x"./zestimate/amount/text()"
      )

    data
    |> Map.put(:market_value, List.to_integer(data[:market_value]))
    |> Map.put(:tax_assessment, List.to_float(data[:tax_assessment]))
  end
end
