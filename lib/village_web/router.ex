defmodule VillageWeb.Router do
  use VillageWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VillageWeb do
    pipe_through [:browser, :protected]

    resources "/posts", PostController
  end

  scope "/", VillageWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  # Other scopes may use custom stacks.
  # scope "/api", VillageWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: VillageWeb.Telemetry, ecto_repos: [MyApp.Repo]
    end
  end
end
