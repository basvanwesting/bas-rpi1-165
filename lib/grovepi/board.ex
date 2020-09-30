defmodule GrovePi.Board do
  @moduledoc """
  Extracted from https://hex.pm/packages/grovepi

  Low-level interface for sending raw requests and receiving responses from a
  GrovePi hat. Automatically started with GrovePi, allows you to use one of the other GrovePi
  modules for interacting with a connected sensor, light, or actuator.

  To check that your GrovePi hardware is working, try this:

  ```elixir
  iex> GrovePi.Board.firmware_version()
  "1.2.2"
  ```

  """

  use GenServer
  @i2c Circuits.I2C
  @i2c_retry_count 2
  @type pin :: integer
  @address 0x04
  @version_cmd 8

  defstruct address: nil, i2c_bus: nil

  ## Client API

  @spec start_link(any) :: {:ok, pid} | {:error, any}
  def start_link(_args) do
    state = %__MODULE__{address: @address}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Get the version of firmware running on the GrovePi's microcontroller.
  """
  @spec firmware_version() :: binary | {:error, term}
  def firmware_version() do
    with :ok <- send_request(<<@version_cmd, 0, 0, 0>>),
         <<_, major, minor, patch>> <- get_response(4),
         do: "#{major}.#{minor}.#{patch}"
  end

  @doc """
  Send a request to the GrovePi. This is not normally called directly
  except when interacting with an unsupported sensor.
  """
  @spec send_request(binary) :: :ok | {:error, term}
  def send_request(message) when byte_size(message) == 4 do
    GenServer.call(__MODULE__, {:write, message})
  end

  @doc """
  Get a response to a previously send request to the GrovePi. This is
  not normally called directly.
  """
  @spec get_response(integer) :: binary | {:error, term}
  def get_response(bytes_to_read) do
    GenServer.call(__MODULE__, {:read, bytes_to_read})
  end

  @doc """
  Write directly to a device on the I2C bus. This is used for sensors
  that are not controlled by the GrovePi's microcontroller.
  """
  def i2c_write_device(address, message) do
    GenServer.call(__MODULE__, {:write_device, address, message})
  end
  @doc """
  Read directly to a device on the I2C bus. This is used for sensors
  that are not controlled by the GrovePi's microcontroller.
  """
  def i2c_read_device(address, bytes_to_read) do
    GenServer.call(__MODULE__, {:read_device, address, bytes_to_read})
  end

  ## Server Callbacks

  @impl true
  def init(state) do
    {:ok, state, {:continue, :open_i2c}}
  end

  @impl true
  def handle_continue(:open_i2c, state) do
    {:ok, ref} = @i2c.open("i2c-1")
    {:noreply, %{state | i2c_bus: ref}}
  end

  @impl true
  def handle_call({:write, message}, _from, state) do
    reply = @i2c.write(state.i2c_bus, state.address, message, retries: @i2c_retry_count)
    {:reply, reply, state}
  end

  @impl true
  def handle_call({:write_device, address, message}, _from, state) do
    reply = @i2c.write(state.i2c_bus, address, message, retries: @i2c_retry_count)
    {:reply, reply, state}
  end

  @impl true
  def handle_call({:read_device, address, bytes_to_read}, _from, state) do
    reply =
      case(@i2c.read(state.i2c_bus, address, bytes_to_read, retries: @i2c_retry_count)) do
        {:ok, response} -> response
        {:error, error} -> {:error, error}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:read, bytes_to_read}, _from, state) do
    reply =
      case(@i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: @i2c_retry_count)) do
        {:ok, response} -> response
        {:error, error} -> {:error, error}
      end

    {:reply, reply, state}
  end

end
