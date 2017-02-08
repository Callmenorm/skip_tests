defmodule SkipTests do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(SkipTests.Parse.Scheduler, [])
    ]

    opts = [strategy: :one_for_one, name: SkipTests.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
