defmodule MintDigital.Query do
  use GenStage
  @moduledoc """
    > {_, pid} = MintDigital.join(:dummy)
    > Enum.map(["q","qu","qua"], &MintDigital.Query.update(pid, &1))
  """

  # Client
  # This keeps the socket as state
  def start_link(socket), do: GenStage.start_link(__MODULE__, socket)

  # Used by the pid assigned to the socket to call this server's handle_cast
  def update(pid, event), do: GenStage.cast(pid, {:notify, event})

  # Server
  def init(socket), do: {:producer, socket, buffer_size: 1}

  def handle_cast({:notify, event}, socket) do
    {:noreply, [{socket, event}], socket}
  end

  def handle_demand(_demand, state), do: {:noreply, [], state}
end

defmodule MintDigital.QueryRateLimiter do
  use GenStage

  # Client
  def start_link(:ok), do: GenStage.start_link(__MODULE__, :ok, name: __MODULE__)

  # Server
  def init(:ok), do: {:producer_consumer, %{}}

  def handle_subscribe(:producer, opts, from, producers) do
    pending = opts[:max_demand] || 1
    interval = opts[:interval] || 3000

    producers =
      producers
      |> Map.put(from, {pending, interval})
      |> ask_and_schedule(from)

    {:manual, producers}
  end
  def handle_subscribe(:consumer, _opts, _from, consumers) do
    {:automatic, consumers}
  end

  def handle_cancel(_, from, producers), do: Map.delete(producers, from)

  def handle_events(events, _from, state), do: {:noreply, events, state}

  def handle_info({:ask, from}, producers) do
    {:noreply, [], ask_and_schedule(producers, from)}
  end

  defp ask_and_schedule(producers, from) do
    case producers do
      %{^from => {pending, interval}} ->
        GenStage.ask(from, pending)
        Process.send_after(self(), {:ask, from}, interval)
        producers
      %{} ->
        producers
    end
  end
end

defmodule MintDigital.QueryRunner do
  use GenStage
  # import Phoenix.Channel, only: [push: 3]

  # Client
  def start_link(:ok), do: GenStage.start_link(__MODULE__, :ok, name: __MODULE__)

  # Server
  def init(:ok), do: {:consumer, :ok, subscribe_to: [MintDigital.QueryRateLimiter]}

  def handle_events([{_socket, ""}], _from, state), do: {:noreply, [], state}
  def handle_events([{socket, query}], _from, state) do
    MintDigital.Search.run(query).body
    |> push_results(socket)

    {:noreply, [], state}
  end

  defp push_results(results, _socket) do
    # push socket, "results", %{"results" => results}
    IO.inspect results
  end
end

defmodule MintDigital.Search do
  def run(query) do
    Process.sleep(500)
    if byte_size(query) > 3 do
      %{body: "Exact" <> query}
    else
      %{body: query}
    end
  end
end

defmodule MintDigital do

  # handle_info, PhoenixChannel
  # > MintDigital.join(:dummy_socket)
  def join(socket) do
    {:ok, producer_pid} = setup_genstage(socket)
    # were this a real socket, we'd return: assign(socket, :producer_pid, producer_pid)
    {:noreply, producer_pid} # but a 'socket' for us is a pid.
  end

  # handle_in, PhoenixChannel
  def incoming("search", %{"query" => query}, socket) do
    MintDigital.Query.update(socket, query)

    {:noreply, socket}
  end

  defp setup_genstage(socket) do
    {:ok, query_producer} = MintDigital.Query.start_link(socket)

    # Use a shared QueryRateLimiter
    GenStage.sync_subscribe(MintDigital.QueryRateLimiter, to: query_producer)

    {:ok, query_producer}
  end
end
