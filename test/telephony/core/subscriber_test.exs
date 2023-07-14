defmodule Telephony.Core.SubscriberTest do
  @moduledoc false

  use ExUnit.Case

  alias Telephony.Core.{Call, Postpaid, Prepaid, Recharge, Subscriber}

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Samuel",
      phone_number: 123,
      type: :prepaid
    }

    # When
    result = Subscriber.new(payload)

    # Then
    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create a postpaid subscriber" do
    payload = %{
      full_name: "Samuel",
      phone_number: 123,
      type: :postpaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Postpaid{spent: 0}
    }

    assert expect == result
  end

  test "make a prepaid call" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Prepaid{credits: 10, recharges: []}
    }

    date = Date.utc_today()

    assert %Subscriber{
             calls: [%Call{time_spent: 1, date: ~D[2023-07-14]}],
             full_name: "Samuel",
             phone_number: 123,
             type: %Prepaid{credits: 8.55, recharges: []}
           } == Subscriber.make_call(subscriber, 1, date)
  end

  test "make a prepaid without call" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Prepaid{credits: 0, recharges: []}
    }

    date = Date.utc_today()

    assert {:error, "Subscriber does not have credits"} ==
             Subscriber.make_call(subscriber, 1, date)
  end

  test "make a postpaid call" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Postpaid{spent: 0}
    }

    date = Date.utc_today()

    assert %Subscriber{
             calls: [%Call{time_spent: 1, date: date}],
             full_name: "Samuel",
             phone_number: 123,
             type: %Postpaid{spent: 1.0}
           } == Subscriber.make_call(subscriber, 1, date)
  end

  test "make a recharge" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Prepaid{credits: 100, recharges: []}
    }

    date = Date.utc_today()

    assert %Subscriber{
             calls: [],
             full_name: "Samuel",
             phone_number: 123,
             type: %Prepaid{
               credits: 101,
               recharges: [%Recharge{value: 1, date: date}]
             }
           } == Subscriber.make_recharge(subscriber, 1, date)
  end

  test "make a recharge for postpaid" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Postpaid{spent: 0}
    }

    date = Date.utc_today()

    assert {:error, "Postpaid can't do a recharge"} ==
             Subscriber.make_recharge(subscriber, 1, date)
  end

  test "print invoice for postpaid" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Postpaid{spent: 0}
    }

    date = Date.utc_today()

    assert %{
             invoice: %{calls: [], value_spent: 0},
             subscirber: %Telephony.Core.Subscriber{
               full_name: "Samuel",
               phone_number: 123,
               type: %Telephony.Core.Postpaid{spent: 0},
               calls: []
             }
           } ==
             Subscriber.print_invoice(subscriber, 1, date)
  end

  test "print invoice for prepaid" do
    subscriber = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: %Prepaid{credits: 100, recharges: []}
    }

    date = Date.utc_today()

    assert %{
             invoice: %{calls: [], credits: 100, recharges: []},
             subscirber: %Telephony.Core.Subscriber{
               calls: [],
               full_name: "Samuel",
               phone_number: 123,
               type: %Telephony.Core.Prepaid{
                 credits: 100,
                 recharges: []
               }
             }
           } ==
             Subscriber.print_invoice(subscriber, 1, date)
  end
end
