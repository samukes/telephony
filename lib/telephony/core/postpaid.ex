defmodule Telephony.Core.Postpaid do
  @moduledoc false

  alias Telephony.Core.Call

  defstruct spent: 0

  defimpl Subscriber, for: Telephony.Core.Postpaid do
    @price_per_minute 1.0

    def print_invoice(_, calls, year, month) do
      calls = Enum.reduce(calls, [], &filter_calls(&1, &2, year, month))
      value_spent = Enum.reduce(calls, 0, &(&1.value_spent + &2))

      %{
        calls: calls,
        value_spent: value_spent
      }
    end

    defp filter_calls(call, acc, year, month) do
      if call.date.year == year and call.date.month == month do
        value_spent = call.time_spent * 1.04
        call = %{date: call.date, time_spent: call.time_spent, value_spent: value_spent}

        acc ++ [call]
      else
        acc
      end
    end

    def make_call(subscriber_type, time_spent, date) do
      subscriber_type
      |> update_spent(time_spent)
      |> add_call(time_spent, date)
    end

    defp update_spent(subscriber_type, time_spent) do
      spent = @price_per_minute * time_spent
      %{subscriber_type | spent: subscriber_type.spent + spent}
    end

    defp add_call(subscriber_type, time_spent, date) do
      {subscriber_type, Call.new(time_spent, date)}
    end

    def make_recharge(_, _, _), do: {:error, "Postpaid can't do a recharge"}
  end
end
