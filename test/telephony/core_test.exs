defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.{Postpaid, Prepaid, Recharge, Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        type: :prepaid
      }
    ]

    payload = %{
      full_name: "Samuel",
      phone_number: 123,
      type: :prepaid
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
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Carlos",
      phone_number: 1234,
      type: :prepaid
    }

    result = Core.create_subscribers(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        type: :prepaid
      },
      %Subscriber{
        full_name: "Carlos",
        phone_number: 1234,
        type: %Prepaid{credits: 0, recharges: []}
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
    payload = Map.put(payload, :type, :anything)

    result = Core.create_subscribers([], payload)

    assert {:error, "Only 'prepaid' or 'postpaid' are accepted"} == result
  end

  test "search a subscriber", %{subscribers: subscribers} do
    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      type: :prepaid
    }

    result = Core.search_subscriber(subscribers, 123)

    assert expect == result
  end

  test "return nil when subscriber does not exist", %{subscribers: subscribers} do
    result = Core.search_subscriber(subscribers, 000)

    assert nil == result
  end

  test "make a recharge prepaid" do
    subscribers = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    date = Date.utc_today()

    result = Core.make_recharge(subscribers, 123, 2, date)

    assert {[
              %Subscriber{
                full_name: "Samuel",
                phone_number: 123,
                type: %Prepaid{
                  credits: 2,
                  recharges: [%Recharge{value: 2, date: date}]
                },
                calls: []
              }
            ],
            %Subscriber{
              full_name: "Samuel",
              phone_number: 123,
              type: %Prepaid{
                credits: 2,
                recharges: [%Recharge{value: 2, date: date}]
              },
              calls: []
            }} == result
  end

  test "make a recharge postpaid" do
    subscribers = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        type: %Postpaid{spent: 0}
      }
    ]

    date = Date.utc_today()

    result = Core.make_recharge(subscribers, 123, 2, date)

    assert {[], {:error, "Postpaid can't do a recharge"}} == result
  end

  test "make a call prepaid" do
    subscribers = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    expect = {[], {:error, "Subscriber does not have credits"}}

    date = Date.utc_today()
    result = Core.make_call(subscribers, 123, 1, date)

    assert expect == result
  end

  test "print invoice" do
    subscribers = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    expect = %{
      invoice: %{calls: [], credits: 0, recharges: []},
      subscirber: %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        type: %Prepaid{credits: 0, recharges: []},
        calls: []
      }
    }

    date = Date.utc_today()
    result = Core.print_invoice(subscribers, 123, date.year, date.month)

    assert expect == result
  end

  test "print all invoices" do
    subscribers = [
      %Subscriber{
        full_name: "Samuel",
        phone_number: 123,
        type: %Prepaid{credits: 5, recharges: []}
      },
      %Subscriber{
        full_name: "Carlos",
        phone_number: 456,
        type: %Prepaid{credits: 2.6, recharges: []}
      },
      %Subscriber{
        full_name: "Arlete",
        phone_number: 789,
        type: %Postpaid{spent: 100}
      }
    ]

    date = Date.utc_today()

    expect = [
      %{
        invoice: %{calls: [], credits: 5, recharges: []},
        subscirber: %Subscriber{
          full_name: "Samuel",
          phone_number: 123,
          type: %Prepaid{credits: 5, recharges: []},
          calls: []
        }
      },
      %{
        invoice: %{calls: [], credits: 2.6, recharges: []},
        subscirber: %Subscriber{
          full_name: "Carlos",
          phone_number: 456,
          type: %Prepaid{credits: 2.6, recharges: []},
          calls: []
        }
      },
      %{
        invoice: %{calls: [], value_spent: 0},
        subscirber: %Subscriber{
          full_name: "Arlete",
          phone_number: 789,
          type: %Postpaid{spent: 100},
          calls: []
        }
      }
    ]

    result = Core.print_invoices(subscribers, date.year, date.month)

    assert expect == result
  end
end
