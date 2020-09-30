
i2c = Circuits.I2C
i2c_retry_count = 2

Integer.to_string(97, 16) #=> "61"

scd30_i2c_address                       = 0x61
scd30_continuous_measurement            = 0x0010
scd30_set_measurement_interval          = 0x4600
scd30_get_data_ready                    = 0x0202
scd30_read_measurement                  = 0x0300
scd30_stop_measurement                  = 0x0104
scd30_automatic_self_calibration        = 0x5306
scd30_set_forced_recalibration_factor   = 0x5204
scd30_set_temperature_offset            = 0x5403
scd30_set_altitude_compensation         = 0x5102
scd30_read_serialnbr                    = 0xd033

scd30_polynomial                        = 0x31 # P(x) = x^8 + x^5 + x^4 + 1 = 100110001

crc_options = %{
  width: 8,
  poly: 0x31,
  init: 0xff,
  refin: false,
  refout: false,
  xorout: 0x00
}

0x92 = CRC.calculate(<<0xBEEF::16>>, crc_options)

{:ok, ref} = i2c.open("i2c-1")
state = %{address: scd30_i2c_address, i2c_bus: ref}

# read data ready
<<cmd_msb::8, cmd_lsb::8>> = <<scd30_get_data_ready::16>>
message = <<scd30_get_data_ready::16>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)
bytes_to_read = 3
reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
{:ok, <<value::16, crc::8>>} = reply


# set interval
interval = 5
<<cmd_msb::8, cmd_lsb::8>> = <<scd30_set_measurement_interval::16>>
<<par_msb::8, par_lsb::8>> = <<interval::16>>
crc = CRC.calculate(<<interval::16>>, crc_options)
IO.puts Integer.to_string(crc,16)

message = <<scd30_set_measurement_interval::16>> <> <<interval::16>> <> <<crc::8>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)

# read measurements
message = <<scd30_read_measurement::16>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)
bytes_to_read = 18
reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
{:ok, <<co2_bytes::48, t_bytes::48, rh_bytes::48>>} = reply

<<co2_m::16, crc_m::8, co2_l::16, crc_l::8>> = << co2_bytes::48>>
<<co2::32>> = <<co2_m::16, co2_l::16>>
<<co2_value::float-signed-32>> = <<co2::32>>
<<t_m::16, crc_m::8, t_l::16, crc_l::8>> = << t_bytes::48>>
<<t::32>> = <<t_m::16, t_l::16>>
<<t_value::float-signed-32>> = <<t::32>>
<<rh_m::16, crc_m::8, rh_l::16, crc_l::8>> = << rh_bytes::48>>
<<rh::32>> = <<rh_m::16, rh_l::16>>
<<rh_value::float-signed-32>> = <<rh::32>>

co2_value
t_value
rh_value

### calculation example
# CO2Concentration = 439
# PPMHumidity = 48.8 %
# Temperature = 27.2 C


raw = <<0x43::8, 0xDB::8, 0xCB::8, 0x8C::8, 0x2E::8, 0x8F::8, 0x41::8, 0xD9::8, 0x70::8, 0xE7::8, 0xFF::8, 0xF5::8, 0x42::8, 0x43::8, 0xBF::8, 0x3A::8, 0x1B::8, 0x74::8>>
<<co2_bytes::48, t_bytes::48, rh_bytes::48>> = raw
<<co2_m::16, crc_m::8, co2_l::16, crc_l::8>> = << co2_bytes::48>>
<<co2::32>> = <<co2_m::16, co2_l::16>>
<<co2_value::float-signed-32>> = <<co2::32>>
<<t_m::16, crc_m::8, t_l::16, crc_l::8>> = << t_bytes::48>>
<<t::32>> = <<t_m::16, t_l::16>>
<<t_value::float-signed-32>> = <<t::32>>
<<rh_m::16, crc_m::8, rh_l::16, crc_l::8>> = << rh_bytes::48>>
<<rh::32>> = <<rh_m::16, rh_l::16>>
<<rh_value::float-signed-32>> = <<rh::32>>

iex(154)> co2_value
439.09515380859375
iex(155)> t_value
27.238279342651367
iex(156)> rh_value
48.80674362182617




