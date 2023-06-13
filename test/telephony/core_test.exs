defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.Subscriber

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        subscriber_type: :prepaid
      }
    ]

    payload = %{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  test "create new subscriber", %{payload: payload} do
    subscribers = []

    result = Core.create_subscribers(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        subscriber_type: :prepaid
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Carlos",
      phone_number: 1234,
      subscriber_type: :prepaid
    }

    result = Core.create_subscribers(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        subscriber_type: :prepaid
      },
      %Subscriber{
        full_name: "Carlos",
        phone_number: 1234,
        subscriber_type: :prepaid
      }
    ]

    assert expect == result
  end

  test "display error when subscriber already exist", %{
    subscribers: subscribers,
    payload: payload
  } do
    result = Core.create_subscribers(subscribers, payload)

    assert {:error, "Subscriber `123`, already exist"} == result
  end

  test "display error when subscriber type not accepted", %{payload: payload} do
    payload = Map.put(payload, :subscriber_type, :anything)

    result = Core.create_subscribers([], payload)

    assert {:error, "Only 'prepaid' or 'postpaid' are accepted"} == result
  end
end
