defmodule BasRpi1165.MonitorSensors do
  @moduledoc false

  use GenServer

  alias Grove.{TemperatureSensor, LCDRGBBacklight}

  @temperature_sensor_pin 0

  @interval 5000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_args) do
    {:ok, nil, {:continue, :connect}}
  end

  def handle_continue(:connect, _state) do
    with {:ok, config} <- LCDRGBBacklight.initialize(),
         {:ok, new_config} <- LCDRGBBacklight.cursor_on(config),
         :ok <- LCDRGBBacklight.set_rgb(25, 25, 25),
         :ok <- LCDRGBBacklight.set_text("initializing...") do
      Process.send_after(self(), :tick, @interval)
      {:noreply, new_config}
    end
  end

  def handle_info(:tick, state) do
    read_sensors() |> display_results()
    Process.send_after(self(), :tick, @interval)
    {:noreply, state}
  end

  def read_sensors do
    %{temperature: TemperatureSensor.read_celsius(@temperature_sensor_pin)}
  end

  def display_results(%{temperature: temperature}) do
    display_temperature = Float.round(temperature, 1)
    LCDRGBBacklight.set_text("#{display_temperature} C")
  end

end
