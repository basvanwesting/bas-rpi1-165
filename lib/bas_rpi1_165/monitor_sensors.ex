defmodule BasRpi1165.MonitorSensors do
  @moduledoc false

  use GenServer

  alias Grove.{TemperatureSensor, LCDRGBBacklight, Scd30}

  @temperature_sensor_pin 0

  @interval 5000

  @lcdrgb_brightness       255
  @co2_ppm_green_threshold 400
  @co2_ppm_red_threshold   800

  defmodule State do
    @moduledoc """
    Module with struct to hold state
    """
    defstruct \
      lcdrgb_config:   nil, \
      co2_ppm:         nil, \
      temperature:     nil, \
      humidity:        nil, \
      temperature_alt: nil
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_args) do
    {:ok, %State{}, {:continue, :connect}}
  end

  def handle_continue(:connect, state) do
    with {:ok, config} <- LCDRGBBacklight.initialize(),
         {:ok, new_config} <- LCDRGBBacklight.cursor_on(config),
         :ok <- LCDRGBBacklight.set_rgb(25, 25, 25),
         :ok <- LCDRGBBacklight.set_text("initializing...") do
      Process.send_after(self(), :tick, @interval)
      {:noreply, %{state | lcdrgb_config: new_config}}
    end
  end

  def handle_info(:tick, state) do
    state = state
            |> read_temperature_sensor
            |> read_scd30_sensor
            |> display_results

    Process.send_after(self(), :tick, @interval)
    {:noreply, state}
  end

  def read_temperature_sensor(%State{} = state) do
    case TemperatureSensor.read_celsius(@temperature_sensor_pin) do
      temp when is_float(temp) -> %{state | temperature_alt: temp}
      _ -> state
    end
  end

  def read_scd30_sensor(%State{} = state) do
    with true <- Scd30.measurement_ready?,
         %Scd30.Measurement{} = measurement <- Scd30.read_measurement do

      %{ state |
        co2_ppm:     measurement.co2_ppm,
        temperature: measurement.temperature,
        humidity:    measurement.humidity
      }
    else
      _ -> state
    end
  end

  def display_results(%State{} = state) do
    formatted_temperature_alt = format_temperature(state.temperature_alt)
    formatted_temperature = format_temperature(state.temperature)
    formatted_humidity = format_humidity(state.humidity)
    formatted_co2_ppm = format_co2_ppm(state.co2_ppm)
    LCDRGBBacklight.clear_display()
    LCDRGBBacklight.write_text(formatted_co2_ppm) # 6
    LCDRGBBacklight.write_text(" ") # 1
    LCDRGBBacklight.write_text(formatted_temperature) #5
    LCDRGBBacklight.write_text(" ") # 1
    LCDRGBBacklight.write_text(formatted_humidity) #3
    LCDRGBBacklight.write_text("\n")
    LCDRGBBacklight.write_text(formatted_temperature_alt)

    LCDRGBBacklight.set_rgb(co2_ppm_to_rgb(state.co2_ppm))
    state
  end

  def format_temperature(value) when is_float(value) do
    "#{Float.round(value, 1)}C"
  end
  def format_temperature(_), do: "--.-C"

  def format_humidity(value) when is_float(value) do
    "#{round(value)}%"
  end
  def format_humidity(_), do: "--%"

  def format_co2_ppm(value) when is_float(value) do
    "#{round(value)}ppm"
  end
  def format_co2_ppm(_), do: "---ppm"

  def co2_ppm_to_rgb(co2_ppm) when is_float(co2_ppm) do
    [
      co2_ppm_to_red(co2_ppm),
      co2_ppm_to_green(co2_ppm),
      0,
    ]
  end
  def co2_ppm_to_rgb(_) do
    [0, 0, @lcdrgb_brightness]
  end

  def co2_ppm_to_red(co2_ppm) when is_float(co2_ppm) do
    cond do
      co2_ppm <= @co2_ppm_green_threshold -> 0
      co2_ppm >= @co2_ppm_red_threshold -> @lcdrgb_brightness
      co2_ppm -> (co2_ppm - @co2_ppm_green_threshold) / (@co2_ppm_red_threshold - @co2_ppm_green_threshold) * @lcdrgb_brightness
    end |> round
  end

  def co2_ppm_to_green(co2_ppm) when is_float(co2_ppm) do
    cond do
      co2_ppm <= @co2_ppm_green_threshold -> @lcdrgb_brightness
      co2_ppm >= @co2_ppm_red_threshold -> 0.0
      co2_ppm -> (1.0 - (co2_ppm - @co2_ppm_green_threshold) / (@co2_ppm_red_threshold - @co2_ppm_green_threshold)) * @lcdrgb_brightness
    end |> round
  end

end
