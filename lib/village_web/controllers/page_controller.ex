defmodule VillageWeb.PageController do
  use VillageWeb, :controller

  def index(conn, _params) do
    if Pow.Plug.current_user(conn) do
      redirect(conn, to: Routes.feed(conn))
    else
      render(conn, "index.html")
    end
  end
end
