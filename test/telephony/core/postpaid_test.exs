defmodule Telephony.Core.PostpaidTest do
  @moduledoc false

  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Postpaid{spent: 0},
      calls: []
    }

    %{subscriber: subscriber}
  end

  test "make a call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    result = Postpaid.make_call(subscriber, time_spent, date)

    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Postpaid{spent: 2.0},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    assert expect == result
  end
end
