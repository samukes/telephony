defmodule Telephony.Core.PrepaidTest do
  @moduledoc false

  use ExUnit.Case

  alias Telephony.Core.{Call, Prepaid, Recharge, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    subscriber_no_credits = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    %{subscriber: subscriber, subscriber_no_credits: subscriber_no_credits}
  end

  test "make a call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    result = Prepaid.make_call(subscriber, time_spent, date)

    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "try to make a call", %{subscriber_no_credits: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    result = Prepaid.make_call(subscriber, time_spent, date)

    expect = {:error, "Subscriber does not have credits"}

    assert expect == result
  end

  test "make a recharge", %{subscriber: subscriber} do
    value = 100
    date = NaiveDateTime.utc_now()

    result = Prepaid.make_recharge(subscriber, value, date)

    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{
        credits: 110,
        recharges: [
          %Recharge{value: 100, date: date}
        ]
      },
      calls: []
    }

    assert expect == result
  end
end
