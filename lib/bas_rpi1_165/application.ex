defmodule BasRpi1165.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: BasRpi1165.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: BasRpi1165.Worker.start_link(arg)
        # {BasRpi1165.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: BasRpi1165.Worker.start_link(arg)
      # {BasRpi1165.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: BasRpi1165.Worker.start_link(arg)
      # {BasRpi1165.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:bas_rpi1_165, :target)
  end
end
