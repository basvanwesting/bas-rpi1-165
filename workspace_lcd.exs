
grovepi_address = 0x04
rgb_address     = 0x62
lcd_address     = 0x3E

i2c = Circuits.I2C
i2c_retry_count = 2


{:ok, ref} = i2c.open("i2c-1")
state = %{address: grovepi_address, i2c_bus: ref}

