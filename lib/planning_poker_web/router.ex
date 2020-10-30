defmodule PlanningPokerWeb.Router do
  use PlanningPokerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PlanningPokerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # TOKEN
  # https://toranbillups.com/blog/archive/2020/06/26/cookie-authentication-with-phoenix-liveview/
  # https://elixir-lang.org/getting-started/mix-otp/ets.html
  # https://github.com/toranb/cookie-authentication-phoenix-liveview-example/commit/863e3c3b7cf4f2a0230c4f036d8a10183adcdc5b

  scope "/", PlanningPokerWeb do
    pipe_through :browser

    live "/", PageLive, :index

    live "/tables", TableLive.Index, :index
    live "/tables/new", TableLive.Index, :new
    live "/tables/:id/edit", TableLive.Index, :edit

    live "/tables/:id", TableLive.Show, :show
    live "/tables/:id/join", TableLive.Show, :join
    live "/tables/:id/show/edit", TableLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlanningPokerWeb do
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
      live_dashboard "/dashboard", metrics: PlanningPokerWeb.Telemetry
    end
  end
end
