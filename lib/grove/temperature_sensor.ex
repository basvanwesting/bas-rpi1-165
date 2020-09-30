defmodule Grove.TemperatureSensor do
  @moduledoc ~S"""
  Temperature Sensor V1.2

  Example usage for pin 0 (A0):
  ```
  iex> temperature = Grove.TemperatureSensor.read_temperature(0)
  22.05
  ```
  """

  alias GrovePi.Analog

  @b  4275 # B value of the thermistor
  @r0 100000 # R0 = 100k

  @spec read_temperature(integer) :: float | {:error, term}
  def read_temperature(pin) when is_integer(pin) do
    Analog.read(pin)
    |> calculate_temperature
  end

  @spec calculate_temperature(pos_integer) :: float
  def calculate_temperature(value) when value > 0 do
    r = 1023.0/value - 1.0
    r = @r0 * r
    1.0 / (:math.log(r/@r0) / @b + 1/298.15) - 273.15
  end

end
