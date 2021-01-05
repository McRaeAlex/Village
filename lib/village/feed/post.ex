defmodule Village.Feed.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string

    belongs_to :author, Village.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
