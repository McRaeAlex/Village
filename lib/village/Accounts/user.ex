defmodule Village.Accounts.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  schema "users" do
    field :role, :string, default: "user"

    pow_user_fields()

    has_many :posts, Village.Accounts.User, foreign_key: :author_id

    timestamps()
  end

end
