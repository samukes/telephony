defmodule Telephony.Core.SubscriberTest do
  @moduledoc false

  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid, Prepaid, Subscriber}

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: :prepaid
    }

    # When
    result = Subscriber.new(payload)

    # Then
    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create a postpaid subscriber" do
    payload = %{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: :postpaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Postpaid{spent: 0}
    }

    assert expect == result
  end

  test "make a prepaid call" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    date = Date.utc_today()

    assert %Subscriber{
             calls: %Call{time_spent: 1, date: date},
             full_name: "Samuel",
             phone_number: 123,
             subscriber_type: %Prepaid{credits: 8.55, recharges: []}
           } == Subscriber.make_call(subscriber, 1, date)
  end

  test "make a prepaid without call" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    date = Date.utc_today()

    assert {:error, "Subscriber does not have credits"} ==
             Subscriber.make_call(subscriber, 1, date)
  end

  test "make a postpaid call" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Postpaid{spent: 0}
    }

    date = Date.utc_today()

    assert %Subscriber{
             calls: %Call{time_spent: 1, date: date},
             full_name: "Samuel",
             phone_number: 123,
             subscriber_type: %Postpaid{spent: 1.0}
           } == Subscriber.make_call(subscriber, 1, date)
  end
end
