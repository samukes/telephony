defmodule Telephony.Core.PrepaidTest do
  @moduledoc false

  use ExUnit.Case

  alias Telephony.Core.{Call, Prepaid, Recharge}

  setup do
    prepaid = %Prepaid{credits: 10, recharges: []}
    prepaid_no_credits = %Prepaid{credits: 0, recharges: []}

    %{prepaid: prepaid, prepaid_no_credits: prepaid_no_credits}
  end

  test "make a call", %{prepaid: prepaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_call(prepaid, time_spent, date)

    expect = {%Prepaid{credits: 7.1, recharges: []}, %Call{time_spent: 2, date: date}}

    assert expect == result
  end

  test "try to make a call", %{prepaid_no_credits: prepaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_call(prepaid, time_spent, date)

    expect = {:error, "Subscriber does not have credits"}

    assert expect == result
  end

  test "make a recharge", %{prepaid: prepaid} do
    value = 100
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_recharge(prepaid, value, date)

    expect = %Prepaid{
      credits: 110,
      recharges: [%Recharge{value: 100, date: date}]
    }

    assert expect == result
  end

  test "print invoice" do
    date = ~D[2023-06-26]
    last_month = ~D[2023-05-26]

    subscriber = %Telephony.Core.Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{
        credits: 253.6,
        recharges: [
          %Recharge{value: 100, date: date},
          %Recharge{value: 100, date: last_month},
          %Recharge{value: 100, date: last_month}
        ]
      },
      calls: [
        %Call{
          time_spent: 2,
          date: date
        },
        %Call{
          time_spent: 10,
          date: last_month
        },
        %Call{
          time_spent: 20,
          date: last_month
        }
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls

    assert(
      Subscriber.print_invoice(subscriber_type, calls, 2023, 05) == %{
        calls: [
          %{
            time_spent: 20,
            value_spent: 29.0,
            date: last_month
          },
          %{
            time_spent: 10,
            value_spent: 14.5,
            date: last_month
          }
        ],
        recharges: [
          %Recharge{value: 100, date: last_month},
          %Recharge{value: 100, date: last_month}
        ],
        credits: 253.6
      }
    )
  end
end
