defmodule Telephony.Core.PostpaidTest do
  @moduledoc false

  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid}

  setup do
    %{postpaid: %Postpaid{spent: 0}}
  end

  test "make a call", %{postpaid: postpaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_call(postpaid, time_spent, date)

    expect =
      {%Telephony.Core.Postpaid{spent: 2.0}, %Telephony.Core.Call{time_spent: 2, date: date}}

    assert expect == result
  end

  test "try to make a recharge" do
    postpaid = %Postpaid{spent: 90 * 1.04}

    assert {:error, "Postpaid can't do a recharge"} =
             Subscriber.make_recharge(postpaid, 100, Date.utc_today())
  end

  test "print invoice" do
    date = ~D[2023-06-26]
    last_month = ~D[2023-05-26]

    postpaid = %Postpaid{spent: 90 * 1.04}

    calls = [
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

    assert expect == Subscriber.print_invoice(postpaid, calls, 2023, 05)
  end
end
