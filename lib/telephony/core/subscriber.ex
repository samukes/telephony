defprotocol Subscriber do
  @fallback_to_any true

  def print_invoice(type, calls, year, month)
  def make_call(type, time_spent, date)
  def make_recharge(type, value, date)
end

defmodule Telephony.Core.Subscriber do
  @moduledoc false

  alias Telephony.Core.{Postpaid, Prepaid}

  defstruct full_name: nil, phone_number: nil, type: :prepaid, calls: []

  def new(%{type: :prepaid} = payload) do
    payload = %{payload | type: %Prepaid{}}

    struct(__MODULE__, payload)
  end

  def new(%{type: :postpaid} = payload) do
    payload = %{payload | type: %Postpaid{}}

    struct(__MODULE__, payload)
  end

  def make_call(subscriber, time_spent, date) do
    case Subscriber.make_call(subscriber.type, time_spent, date) do
      {:error, _} = error -> error
      {type, call} -> %{subscriber | type: type, calls: subscriber.calls ++ [call]}
    end
  end

  def make_recharge(subscriber, value, date) do
    case Subscriber.make_recharge(subscriber.type, value, date) do
      {:error, _} = error -> error
      type -> %{subscriber | type: type}
    end
  end

  def print_invoice(subscriber, year, month) do
    invoice = Subscriber.print_invoice(subscriber.type, subscriber.calls, year, month)

    %{subscirber: subscriber, invoice: invoice}
  end
end
