defmodule Grove.TemperatureSensorV1_2Test do
  use ExUnit.Case
  alias Grove.TemperatureSensorV1_2

  doctest TemperatureSensorV1_2

  test "calculate_temperature/1" do
    temperature = TemperatureSensorV1_2.calculate_temperature(475)
    assert_in_delta(temperature, 22.05, 0.01)
  end
end
