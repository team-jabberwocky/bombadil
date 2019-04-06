defmodule Bombadil.OpenDataBR.StreetAddresses do
  use GenServer

  alias NimbleCSV.RFC4180, as: CSV

  ## Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  def match_prefix(query) do
    GenServer.call(__MODULE__, {:match_prefix, query})
  end

  ## Server

  @impl true
  def init(:ok) do
    Process.send(self(), :initialize_cache, [])
    {:ok, []}
  end

  @impl true
  def handle_info(:initialize_cache, _state) do
    state =
      "priv/street_address_listings.csv"
      |> File.stream!()
      |> CSV.parse_stream()
      |> Stream.map(fn [_, _, _, _, _, _, _, full_address, city, zip, _, _, _] ->
        {full_address, city, zip}
      end)
      |> Enum.to_list()

    {:noreply, state}
  end

  @impl true
  def handle_call({:match_prefix, prefix}, _from, state) do
    matches =
      Enum.filter(state, fn {full_address, _city, _zip} ->
        String.starts_with?(full_address, String.upcase(prefix))
      end)
      |> Enum.take(5)

    {:reply, matches, state}
  end
end
