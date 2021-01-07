defmodule VillageWeb.PostController do
  use VillageWeb, :controller

  alias Village.Feed
  alias Village.Feed.Post

  action_fallback VillageWeb.FallbackController

  def index(conn, _params) do
    user = Pow.Plug.current_user(conn)
    posts = Feed.list_posts()
    render(conn, "index.html", posts: posts, current_user: user)
  end

  def new(conn, _params) do
    changeset = Feed.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    user = Pow.Plug.current_user(conn)

    case Feed.create_post(user, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Feed.get_post!(id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}) do
    user = Pow.Plug.current_user(conn)
    post = Feed.get_post!(id)

    with :ok <- Bodyguard.permit(Feed, :edit, user, post),
      {:ok, changeset} <- Feed.change_post(post)
    do
      render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    user = Pow.Plug.current_user(conn)
    post = Feed.get_post!(id)

    with :ok <- Bodyguard.permit(Feed, :update, user, post) do
      case Feed.update_post(post, post_params) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post updated successfully.")
          |> redirect(to: Routes.post_path(conn, :show, post))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", post: post, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Pow.Plug.current_user(conn)
    post = Feed.get_post!(id)

    with :ok <- Bodyguard.permit(Feed, :delete, user, post),
        {:ok, _post} <- Feed.delete_post(post)
    do
      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.post_path(conn, :index))
    end
  end
end
