defmodule DownloadManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # start Cluster
      {Cluster.Supervisor, [topologies(), [name: BackgroundJob.ClusterSupervisor]]},
      # start Horde
      DownloadManager.HordeRegistry,
      DownloadManager.HordeSupervisor,
      DownloadManager.NodeObserver,
      DownloadManager.Download.Repo,
      {DownloadManager.Cache, []},
      # Start the Telemetry supervisor
      DownloadManagerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DownloadManager.PubSub},
      # Start the Endpoint (http/https)
      DownloadManagerWeb.Endpoint
      # Start a worker by calling: DownloadManager.Worker.start_link(arg)
      # {DownloadManager.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DownloadManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DownloadManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def topologies() do
    [
      background_job: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]
  end
end
