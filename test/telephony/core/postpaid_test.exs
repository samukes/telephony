defmodule Telephony.Core.PostpaidTest do
  @moduledoc false

  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid}

  setup do
    subscriber = %Telephony.Core.Subscriber{
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

    expect = %Telephony.Core.Subscriber{
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

  test "print invoice" do
    date = ~D[2023-06-26]
    last_month = ~D[2023-05-26]

    subscriber = %Telephony.Core.Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Postpaid{spent: 90 * 1.04},
      calls: [
        %Call{
          time_spent: 10,
          date: date
        },
        %Call{
          time_spent: 50,
          date: last_month
        },
        %Call{
          time_spent: 30,
          date: last_month
        }
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls

    expect = %{
      value_spent: 80 * 1.04,
      calls: [
        %{
          time_spent: 50,
          value_spent: 50 * 1.04,
          date: last_month
        },
        %{
          time_spent: 30,
          value_spent: 30 * 1.04,
          date: last_month
        }
      ]
    }

    assert expect == Subscriber.print_invoice(subscriber_type, calls, 2023, 05)
  end
end
