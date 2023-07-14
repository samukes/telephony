defmodule Telephony.Core do
  @moduledoc false

  alias __MODULE__.Subscriber

  @types ~w(prepaid postpaid)a

  def create_subscribers(subscribers, %{type: type} = payload)
      when type in @types do
    case Enum.find(subscribers, &(&1.phone_number == payload.phone_number)) do
      nil -> subscribers ++ [Subscriber.new(payload)]
      subscriber -> {:error, "Subscriber `#{subscriber.phone_number}`, already exist"}
    end
  end

  def create_subscribers(_, _),
    do: {:error, "Only 'prepaid' or 'postpaid' are accepted"}

  def search_subscriber(subscribers, phone_number) do
    Enum.find(subscribers, &(&1.phone_number == phone_number))
  end

  def make_recharge(subscribers, phone_number, value, date) do
    subscribers
    |> search_subscriber(phone_number)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        subscribers = List.delete(subscribers, subscriber)
        result = Subscriber.make_recharge(subscriber, value, date)
        update_subscriber(subscribers, result)
      end
    end)
  end

  defp update_subscriber(subscribers, {:error, _} = err) do
    {subscribers, err}
  end

  defp update_subscriber(subscribers, subscriber) do
    {subscribers ++ [subscriber], subscriber}
  end

  def make_call(subscribers, phone_number, time_spent, date) do
    subscribers
    |> search_subscriber(phone_number)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        subscribers = List.delete(subscribers, subscriber)
        result = Subscriber.make_call(subscriber, time_spent, date)
        update_subscriber(subscribers, result)
      end
    end)
  end

  def print_invoice(subscribers, phone_number, year, month) do
    subscribers
    |> search_subscriber(phone_number)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        Subscriber.print_invoice(subscriber, year, month)
      end
    end)
  end

  def print_invoices(subscribers, year, month) do
    Enum.map(subscribers, &Subscriber.print_invoice(&1, year, month))
  end
end
