defmodule Neoprice.Cryptocompare.ApiTest do
  @moduledoc "tests on the API"
  use ExUnit.Case
  alias Neoprice.Cryptocompare.Api
  import Mock

  test "minute report" do
    now = DateTime.utc_now() |> DateTime.to_unix()
    prices = Api.get_historical_price(:minute, "NEO", "BTC", 100, 1, now)
    assert_in_delta List.last(prices) |> elem(0), now, 60
  end

  test "hour report" do
    now = DateTime.utc_now() |> DateTime.to_unix()
    prices = Api.get_historical_price(:hour, "NEO", "BTC", 100, 1, now)
    assert_in_delta List.last(prices) |> elem(0), now, 3600
  end

  test "day report" do
    now = DateTime.utc_now() |> DateTime.to_unix()
    prices = Api.get_historical_price(:day, "NEO", "BTC", 100, 1, now)
    assert_in_delta List.last(prices) |> elem(0), now, 24 * 3600
  end

  test "day report error json" do
    now = DateTime.utc_now() |> DateTime.to_unix()

    with_mock Neoprice.Helper,
      retry_get: fn _url -> {:ok, %{status_code: 200, body: "nonjson"}} end do
      assert [] == Api.get_historical_price(:hour, "NEO", "BTC", 100, 1, now)
    end
  end

  test "day report error status" do
    now = DateTime.utc_now() |> DateTime.to_unix()

    with_mock Neoprice.Helper,
      retry_get: fn _url -> {:ok, %{status_code: 500, body: "nonjson"}} end do
      assert [] == Api.get_historical_price(:hour, "NEO", "BTC", 100, 1, now)
    end
  end

  test "last" do
    assert is_number(Api.last_price("NEO", "BTC"))
  end

  test "last_price_full/2" do
    assert is_map(Api.last_price_full("NEO", "BTC"))
  end
end
