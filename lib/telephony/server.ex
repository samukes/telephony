defmodule Telephony.Server do
  @moduledoc false

  alias Telephony.Core

  @behaviour GenServer

  def start_link(server_name) do
    GenServer.start_link(__MODULE__, [], name: server_name)
  end

  def init(subscribers), do: {:ok, subscribers}

  def handle_call({:create_subscriber, payload}, _from, state) do
    case Core.create_subscribers(state, payload) do
      {:error, _} = err -> {:reply, err, state}
      subscribers -> {:reply, subscribers, subscribers}
    end
  end

  def handle_call({:search_subscriber, phone_number}, _from, state) do
    subscriber = Core.search_subscriber(state, phone_number)

    {:reply, subscriber, state}
  end

  def handle_cast({:make_recharge, phone_number, value, date}, state) do
    case Core.make_recharge(state, phone_number, value, date) do
      {:error, _} -> {:noreply, state}
      subscriber -> {:noreply, state ++ [subscriber]}
    end
  end
end
