defmodule Telephony.Core do
  @moduledoc false

  alias __MODULE__.Subscriber

  @subscriber_types ~w(prepaid postpaid)a

  def create_subscribers(subscribers, %{subscriber_type: type} = payload)
      when type in @subscriber_types do
    case Enum.find(subscribers, &(&1.phone_number == payload.phone_number)) do
      nil -> subscribers ++ [Subscriber.new(payload)]
      subscriber -> {:error, "Subscriber `#{subscriber.phone_number}`, already exist"}
    end
  end

  def create_subscribers(_, _),
    do: {:error, "Only 'prepaid' or 'postpaid' are accepted"}
end
