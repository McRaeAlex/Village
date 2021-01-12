defmodule Village.Accounts do
  alias Village.Repo
  alias Village.Accounts.User
  alias Village.Feed.Post

  def get_user!(id) do
    Repo.get!(User, id)
  end
end
