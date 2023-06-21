defmodule Telephony.Core.Postpaid do
  @moduledoc false

  alias Telephony.Core.Call

  defstruct spent: 0

  @price_per_minute 1.0

  def make_call(subscriber, time_spent, date) do
    subscriber
    |> update_spent(time_spent)
    |> add_call(time_spent, date)
  end

  defp update_spent(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    spent = @price_per_minute * time_spent
    subscriber_type = %{subscriber_type | spent: subscriber_type.spent + spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_call(subscriber, time_spent, date) do
    %{subscriber | calls: subscriber.calls ++ [Call.new(time_spent, date)]}
  end
end
