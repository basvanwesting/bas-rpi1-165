defmodule Grove.TemperatureSensorTest do
  use ExUnit.Case
  alias Grove.TemperatureSensor

  doctest TemperatureSensor

  test "calculate_temperature/1" do
    temperature = TemperatureSensor.calculate_temperature(475)
    assert_in_delta(temperature, 22.05, 0.01)
  end
end
