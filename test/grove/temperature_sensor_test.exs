defmodule Grove.TemperatureSensorTest do
  use ExUnit.Case
  alias Grove.TemperatureSensor

  #doctest TemperatureSensor

  test "calculate_celsius/1" do
    temperature = TemperatureSensor.calculate_celsius(475)
    assert_in_delta(temperature, 22.05, 0.01)
  end
end
