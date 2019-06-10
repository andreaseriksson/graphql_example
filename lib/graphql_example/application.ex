defmodule GraphqlExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      GraphqlExample.Repo,
      # Start the endpoint when the application starts
      GraphqlExampleWeb.Endpoint
      # Starts a worker by calling: GraphqlExample.Worker.start_link(arg)
      # {GraphqlExample.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GraphqlExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GraphqlExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
