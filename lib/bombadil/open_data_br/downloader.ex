defmodule Bombadil.OpenDataBR.Downloader do
  def download(url, filename) do
    file =
      case File.exists?(filename) do
        true ->
          File.open!(filename, [:append])

        false ->
          File.touch!(filename)
          File.open!(filename, [:append])
      end

    %HTTPoison.AsyncResponse{id: ref} = HTTPoison.get!(url, %{}, stream_to: self())

    append(ref, file)
  end

  defp append(ref, file) do
    receive do
      %HTTPoison.AsyncChunk{chunk: chunk, id: ^ref} ->
        IO.binwrite(file, chunk)
        append(ref, file)

      %HTTPoison.AsyncEnd{id: ^ref} ->
        File.close(file)

      %HTTPoison.Error{reason: _reason} ->
        :error
    end
  end
end
