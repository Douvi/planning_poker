defmodule PlanningPoker.Repo do
  use Ecto.Repo,
    otp_app: :planning_poker,
    adapter: Ecto.Adapters.Postgres
end
