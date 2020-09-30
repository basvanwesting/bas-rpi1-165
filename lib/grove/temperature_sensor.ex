defmodule Grove.TemperatureSensor do
  @moduledoc ~S"""
  Temperature Sensor V1.2

  Reads temperature in Celsius.
  Example usage for pin 0 (A0):
  ```
  iex> temperature = Grove.TemperatureSensor.read_celsius(0)
  22.05
  ```
  """

  alias GrovePi.Analog

  @b  4275 # B value of the thermistor
  @r0 100000 # R0 = 100k

  @spec read_celsius(integer) :: float | {:error, term}
  def read_celsius(pin) when is_integer(pin) do
    Analog.read(pin)
    |> calculate_celsius
  end

  @spec calculate_celsius(pos_integer) :: float
  def calculate_celsius(value) when value > 0 do
    r = 1023.0/value - 1.0
    r = @r0 * r
    1.0 / (:math.log(r/@r0) / @b + 1/298.15) - 273.15
  end

end
