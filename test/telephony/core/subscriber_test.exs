defmodule Telephony.Core.SubscriberTest do
  @moduledoc false

  use ExUnit.Case

  alias Telephony.Core.Subscriber
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Postpaid

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: :prepaid
    }

    # When
    result = Subscriber.new(payload)

    # Then
    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create a postpaid subscriber" do
    payload = %{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: :postpaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Samuel",
      phone_number: 123,
      subscriber_type: %Postpaid{spent: 0}
    }

    assert expect == result
  end
end
