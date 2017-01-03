defmodule Metex.Worker do

  @owm_key Application.get_env(:metex, :owm_api_key)
  @owm_url Application.get_env(:metex, :owm_url)

  def temperature_of(location) do
    location |> url_for |> HTTPoison.get |> parse_response |> handle_result
  end

  defp url_for(location) do
    location = location |> URI.encode

    "#{@owm_url}?q=#{location}&appid=#{@owm_key}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> convert_from_kelvin
  end

  defp parse_response(_) do
    :error
  end

  defp convert_from_kelvin(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)

      {:ok, temp}
    rescue
      _ -> :error
    end
  end
end
