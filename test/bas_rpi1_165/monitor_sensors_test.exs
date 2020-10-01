defmodule BasRpi1165.MonitorSensorsTest do
  use ExUnit.Case
  alias BasRpi1165.MonitorSensors

  #doctest MonitorSensors

  test "co2_ppm_to_rgb/1" do
    assert MonitorSensors.co2_ppm_to_rgb(300.0) == [0,255,0]
    assert MonitorSensors.co2_ppm_to_rgb(400.0) == [0,255,0]
    assert MonitorSensors.co2_ppm_to_rgb(500.0) == [64,191,0]
    assert MonitorSensors.co2_ppm_to_rgb(600.0) == [128,128,0]
    assert MonitorSensors.co2_ppm_to_rgb(700.0) == [191,64,0]
    assert MonitorSensors.co2_ppm_to_rgb(800.0) == [255,0,0]
    assert MonitorSensors.co2_ppm_to_rgb(900.0) == [255,0,0]
    assert MonitorSensors.co2_ppm_to_rgb(nil)   == [0,0,255]
  end

end

