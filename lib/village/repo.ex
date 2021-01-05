defmodule Village.Repo do
  use Ecto.Repo,
    otp_app: :village,
    adapter: Ecto.Adapters.Postgres
end
