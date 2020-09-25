
grovepi_address = 0x04
i2c = Circuits.I2C
i2c_retry_count = 2


{:ok, ref} = i2c.open("i2c-1")
state = %{address: grovepi_address, i2c_bus: ref}

message = <<8, 0, 0, 0>>

reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)

bytes_to_read = 4

reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
{:ok, <<_, major, minor, patch>>} = reply



### ANALOG POTENTIOMETER on A1

pin = 1
message = <<3, pin, 0, 0>>

reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)

bytes_to_read = 3
reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
{:ok, <<_, value::size(16)>>} = reply

for i <- 1..100 do
  pin = 1
  message = <<3, pin, 0, 0>>
  reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)
  bytes_to_read = 3
  reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
  {:ok, <<_, value::size(16)>>} = reply
  IO.puts value

  :timer.sleep(1000)
end


### DIGITAL buzzer on D3

input_mode = 0
output_mode = 1
pin = 3

message = <<5, pin, output_mode, 0>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)
message = <<2, pin, 1, 0>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)
:timer.sleep(100)
message = <<2, pin, 0, 0>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)


### DIGITAL button on D3

input_mode = 0
output_mode = 1
pin = 3
bytes_to_read = 1

message = <<5, pin, input_mode, 0>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)

message = <<1, pin, 0, 0>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)

reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
{:ok, <<value::size(8)>>} = reply

for i <- 1..100 do
  pin = 3
  bytes_to_read = 1

  message = <<1, pin, 0, 0>>
  reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)

  reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
  {:ok, <<value::size(8)>>} = reply

  IO.puts "Button: #{value}"

  :timer.sleep(100)
end


### ANALOG TEMP METER on A0

pin = 0

message = <<3, pin, 0, 0>>
reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)

bytes_to_read = 3
reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
{:ok, <<_, value::size(16)>>} = reply

b = 4275 # B value of the thermistor
r0 = 100000 # R0 = 100k
r = 1023.0/value - 1.0
r = r0 * r
temperature = 1.0/(:math.log(r/r0)/b+1/298.15)-273.15


for i <- 1..100 do
  pin = 0

  message = <<3, pin, 0, 0>>
  reply = i2c.write(state.i2c_bus, state.address, message, retries: i2c_retry_count)

  bytes_to_read = 3
  reply = i2c.read(state.i2c_bus, state.address, bytes_to_read, retries: i2c_retry_count)
  {:ok, <<_, value::size(16)>>} = reply

  b = 4275 # B value of the thermistor
  r0 = 100000 # R0 = 100k
  r = 1023.0/value - 1.0
  r = r0 * r
  temperature = 1.0/(:math.log(r/r0)/b+1/298.15)-273.15
  IO.puts "#{temperature} C (from measured #{value})"

  :timer.sleep(1000)
end

