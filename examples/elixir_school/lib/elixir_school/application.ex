defmodule ElixirSchool.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def basic do
    [
      {ElixirSchool.Producer, 0},
      ElixirSchool.ProducerConsumer,
      ElixirSchool.Consumer
    ]
  end
  def multiple_consumers do
    [
      {ElixirSchool.Producer, 0},
      ElixirSchool.ProducerConsumer,
      Supervisor.child_spec({ElixirSchool.Consumer, [:hello]}, id: 1),
      Supervisor.child_spec({ElixirSchool.Consumer, [:hello]}, id: 2)
    ]
  end

  def start(_type, _args) do
    # List all child processes to be supervised
    children = basic()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirSchool.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
