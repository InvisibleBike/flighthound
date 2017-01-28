defmodule Flighthound.SkyscannerAPI do
  require Logger
  use Tesla

  plug Tesla.Middleware.Retry, delay: 500, max_retries: 2
  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.Headers, %{"User-Agent" => "Flighthound v1"}

  adapter Tesla.Adapter.Hackney

  def client_version do
    {:ok, vsn} = Application.get_key(:flighthound, :vsn)
    List.to_string(vsn)
  end

  defp get_config do
    Application.get_env(:flighthound, __MODULE__)
  end

# curl "http://partners.api.skyscanner.net/apiservices/browsequotes/v1.0/RU/USD/en-US/BKK/PEN/2017-02-25/?apiKey=vr928324563992899372427253779891" -X GET -H "Accept: application/json"
  def resource_url(from, to, date, return_date \\ "") do
    config = get_config() |> Map.new
    "#{config.url}/#{config.country}/#{config.currency}/#{config.locale}/#{from}/#{to}/#{date}/#{return_date}"
  end

  def query do
    [apiKey: get_config()[:key]]
  end

  def get_flights(from, to, date) do
    date = date |> Timex.format!("%Y-%m-%d", :strftime)
    get resource_url(from, to, date), query: query()
  end
end