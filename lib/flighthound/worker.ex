defmodule Flighthound.Worker do
  use GenServer
  alias Flighthound.SkyscannerAPI

  # Client API

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def get_flights(pid, from, to, date) do
    GenServer.call(pid, {:get_flights, from, to, date})
  end

  # Server implementation

  def init([]) do
    {:ok, []}
  end

  def handle_call({:get_flights, from, to, date}, _from, state) do
    {:ok, date} = date |> Timex.parse("{YYYY}-{0M}-{0D}")
    flights = SkyscannerAPI.get_flights(from, to, date).body
    carriers = flights["Carriers"]
      |> Enum.map(fn (%{"CarrierId" => cid, "Name" => name}) -> {cid, name} end)
      |> Map.new
    quotes = flights["Quotes"]
      |> Enum.map(fn (%{"MinPrice" => price, "OutboundLeg" => out_leg, "QuoteDateTime" => out_date}) ->
        %{"CarrierIds" => carrier_ids} = out_leg
        [carrier|_] = carrier_ids
        IO.puts "#{from} -> #{to}, #{out_date}, #{carriers[carrier]}, #{price}"
      end)
    {:reply, :ok, state}
  end
end