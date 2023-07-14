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
end
