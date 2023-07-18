defmodule Telephony.ServerTest do
  use ExUnit.Case

  alias Telephony.Server

  setup do
    process_name = :test
    {:ok, pid} = Server.start_link(process_name)

    %{pid: pid, process_name: process_name}
  end

  test "Telephony Server subscribers must be empty", %{pid: pid} do
    assert [] = :sys.get_state(pid)
  end

  test "Create a subscriber must change state", %{pid: pid, process_name: process_name} do
    payload = %{
      name: "Gustavo",
      type: :prepaid,
      phone_number: 123
    }

    old_state = :sys.get_state(pid)
    result = GenServer.call(process_name, {:create_subscriber, payload})

    assert [] == old_state
    refute old_state == result
  end

  test "Duplicate subscriber creation must return an error", %{
    pid: pid,
    process_name: process_name
  } do
    payload = %{
      name: "Gustavo",
      type: :prepaid,
      phone_number: 123
    }

    old_state = :sys.get_state(pid)

    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:create_subscriber, payload})

    assert [] == old_state

    assert {:error, "Subscriber `123`, already exist"} == result
  end

  test "Search subscriber must return a subscriber", %{process_name: process_name} do
    payload = %{
      name: "Gustavo",
      type: :prepaid,
      phone_number: 123
    }

    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:search_subscriber, payload.phone_number})

    assert %Telephony.Core.Subscriber{
             full_name: nil,
             phone_number: 123,
             type: %Telephony.Core.Prepaid{credits: 0, recharges: []},
             calls: []
           } == result
  end

  test "Make recharge must return a recharged subscriber", %{pid: pid, process_name: process_name} do
    payload = %{
      name: "Gustavo",
      type: :prepaid,
      phone_number: 123
    }

    GenServer.call(process_name, {:create_subscriber, payload})

    state = :sys.get_state(pid)
    subscriber = hd(state)
    assert [] == subscriber.type.recharges

    date = Date.utc_today()
    result = GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100, date})

    state = :sys.get_state(pid)
    subscriber = hd(state)
    assert [] == subscriber.type.recharges

    assert :ok == result
  end
end
