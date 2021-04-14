defmodule Village.Feed do
  @moduledoc """
  The Feed context.
  """
  @behaviour Bodyguard.Policy

  import Ecto.Query, warn: false
  alias Village.Repo

  alias Village.Feed.Post
  alias Village.Accounts.User

  def authorize(action, %User{} = user, %Post{} = post)
      when action in [:update, :delete, :edit] do
    cond do
      user.role == "admin" -> :ok
      user.id == post.author_id -> :ok
      true -> {:error, :unauthorized}
    end
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(page, per_page) do
    page = max(page, 1)
    per_page = min(per_page, 50)

    query =
      from p in Post,
        offset: ^((page - 1) * per_page),
        limit: ^per_page,
        order_by: [desc: p.inserted_at]

    Repo.all(query)
    |> Repo.preload(:author)
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts() do
    query =
      from p in Post,
        order_by: [desc: p.inserted_at]

    Repo.all(query)
    |> Repo.preload(:author)
  end

  @doc """
  Returns the list of posts owned by a user.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_user_posts(%User{} = user) do
    query =
      from p in Post,
        where: p.author_id == ^user.id,
        order_by: [desc: p.inserted_at]

    Repo.all(query)
    |> Enum.map(fn post -> set_author(post, user) end)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Repo.get!(Post, id)
    |> Repo.preload(:author)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Village.Accounts.User{} = author, attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_change(:author_id, author.id)
    |> Repo.insert()
    |> maybe_set_author(author)
    |> broadcast(:post_created)
  end

  defp maybe_set_author({:error, _reason} = error, _author), do: error
  defp maybe_set_author({:ok, post}, author), do: {:ok, set_author(post, author)}

  defp set_author(post, author) do
    Map.put(post, :author, author)
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
    |> broadcast(:post_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Village.PubSub, "posts")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, post} = ok, event) do
    Phoenix.PubSub.broadcast(Village.PubSub, "posts", {event, post})
    ok
  end
end
