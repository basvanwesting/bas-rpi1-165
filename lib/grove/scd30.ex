defmodule Grove.Scd30 do
  @moduledoc ~S"""
  CO2 & Temperature & Humidity Sensor v1.0 (SCD30)
  """

  @scd30_i2c_address                      0x61
  @scd30_continuous_measurement           0x0010
  @scd30_set_measurement_interval         0x4600
  @scd30_get_data_ready                   0x0202
  @scd30_read_measurement                 0x0300
  @scd30_read_measurement_number_of_bytes 18
  @scd30_stop_measurement                 0x0104
  @scd30_automatic_self_calibration       0x5306
  @scd30_set_forced_recalibration_factor  0x5204
  @scd30_set_temperature_offset           0x5403
  @scd30_set_altitude_compensation        0x5102
  @scd30_read_serialnbr                   0xd033
  @scd30_polynomial                       0x31 # P(x) = x^8 + x^5 + x^4 + 1 = 100110001

  @crc_options %{
    width: 8,
    poly: @scd30_polynomial,
    init: 0xff,
    refin: false,
    refout: false,
    xorout: 0x00
  }

  alias GrovePi.Board

  defmodule Measurement do
    @moduledoc """
    Module with struct to hold measurement
    """
    defstruct co2_ppm: :none, temperature: :none, humidity: :none
  end

  def calculate_crc(value) when is_integer(value)  do
    calculate_crc(<<value::16>>)
  end
  def calculate_crc(value) when is_binary(value)  do
    CRC.calculate(value, @crc_options)
  end

  def valid_crc?(value, crc) when is_integer(crc) do
    calculate_crc(value) == crc
  end

  def build_message(command) when is_integer(command) do
    <<command::16>>
  end
  def build_message(command, value) when is_integer(command) and is_integer(value) do
    <<command::16, value::16, calculate_crc(value)::8>>
  end

  def set_interval(interval) when interval >= 2 and interval < 1000 do
    message = build_message(@scd30_set_measurement_interval, interval)
    Board.i2c_write_device(@scd30_i2c_address, message)
  end

  def read_measurement() do
    message = build_message(@scd30_read_measurement)
    Board.i2c_write_device(@scd30_i2c_address, message)
    reply = Board.i2c_read_device(@scd30_i2c_address, @scd30_read_measurement_number_of_bytes)
    parse_measurement(reply)
  end

  def parse_measurement(bytes) when is_binary(bytes) do
    <<co2_ppm_bytes::binary-size(6), temperature_bytes::binary-size(6), humidity_bytes::binary-size(6)>> = bytes

    %Measurement{
      co2_ppm:     convert_single_measurement_bytes_to_float(co2_ppm_bytes),
      temperature: convert_single_measurement_bytes_to_float(temperature_bytes),
      humidity:    convert_single_measurement_bytes_to_float(humidity_bytes),
    }
  end

  def convert_single_measurement_bytes_to_float(value) when is_binary(value) do
    <<msb::binary-size(2), _, lsb::binary-size(2), _>> = value
    <<result::float-signed-32>> = msb <> lsb
    result
  end

  def validate_single_measurement_bytes(value) when is_binary(value) do
    <<msb::binary-size(2), crc_msb::8, lsb::binary-size(2), crc_lsb::8>> = value
    valid_crc?(msb, crc_msb) && valid_crc?(lsb, crc_lsb)
  end

end
