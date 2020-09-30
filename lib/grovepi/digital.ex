defmodule GrovePi.Digital do
  alias GrovePi.Board

  @moduledoc """
  Write to and read digital I/O on the GrovePi. This module provides a low
  level API to digital sensors.

  Example usage:
  ```
  iex> pin = 3

  iex> GrovePi.Digital.set_pin_mode(pin, :input)
  :ok
  iex> GrovePi.Digital.read(pin, 0)
  1
  iex> GrovePi.Digital.set_pin_mode(pin, :output)
  :ok
  iex> GrovePi.Digital.write(pin, 1)
  :ok
  iex> GrovePi.Digital.write(pin, 0)
  :ok
  ```
  """

  @type pin_mode :: :input | :output
  @type level :: 0 | 1

  @read_cmd  1
  @write_cmd 2
  @mode_cmd  5

  @doc """
  Configure a digital I/O pin to be an `:input` or an `:output`.
  """
  @spec set_pin_mode(Board.pin(), pin_mode) :: :ok | {:error, term}
  def set_pin_mode(pin, pin_mode) do
    Board.send_request(<<@mode_cmd, pin, mode(pin_mode), 0>>)
  end

  @doc """
  Read the value on a digital I/O pin. Before this is called, the pin must be
  configured as an `:input` with `set_pin_mode/2` or `set_pin_mode/3`.
  """
  @spec read(Board.pin()) :: level | {:error, term}
  def read(pin) do
    with :ok <- Board.send_request(<<@read_cmd, pin, 0, 0>>),
         <<value>> = Board.get_response(1),
         do: value
  end

  @doc """
  Write a value on a digital I/O pin. Before this is called, the pin must be
  configured as an `:output` with `set_pin_mode/2` or `set_pin_mode/3`. Valid
  values are `0` (low) and `1` (high).
  """
  @spec write(Board.pin(), level) :: :ok | {:error, term}
  def write(pin, value) when value == 0 or value == 1 do
    Board.send_request(<<@write_cmd, pin, value, 0>>)
  end

  defp mode(:input), do: 0
  defp mode(:output), do: 1
end
