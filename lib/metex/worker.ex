defmodule Metex.Worker do

  @owm_key Application.get_env(:metex, :owm_api_key)
  @owm_url Application.get_env(:metex, :owm_url)

  @doc """
  iex> cities = ["Singapore", "Monaco", "Vatican City", "Hong Kong", "Macau"]
  iex> Metex.Worker.temperatures_of(cities)
  """
  def temperatures_of(cities) do
    coordinator_pid = spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])

    cities |> Enum.each(fn city ->
      worker_pid = spawn(Metex.Worker, :loop, [])
      send(worker_pid, {coordinator_pid, city})
    end)
  end

  @doc """
  iex> cities = ["Singapore", "Monaco", "Vatican City", "Hong Kong", "Macau"]
  iex> cities |> Enum.each(&(spawn(Metex.Worker, :loop, []) |> send({self, &1})))
  """
  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})
      _ ->
        IO.puts "Don't know how to process this message"
    end
    loop
  end

  def temperature_of(location) do
    location |> url_for |> HTTPoison.get |> parse_response |> handle_result(location)
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

  defp handle_result({:ok, temp}, location), do: "#{location}: #{temp}ªC"
  defp handle_result(:error, location),      do: "#{location} not found"
end
