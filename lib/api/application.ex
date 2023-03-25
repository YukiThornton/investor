defmodule Api.Application do

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Api.Router, options: [port: 7890]}
    ]

    opts = [strategy: :one_for_one, name: Api.Supervisor]

    Logger.info("Starting application")
    Supervisor.start_link(children, opts)
  end

end
