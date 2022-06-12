defmodule Api.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "hello")
  end

  get "/plans" do
    budget = %{max: 50.0, min: 40.0}
    portfolio = [
      %{:ticker => "HOG", :price => 10.2, :holdings => 2, :target_ratio => 0.3},
      %{:ticker => "FUG", :price => 15.1, :holdings => 1, :target_ratio => 0.7}
    ]

    result = App.Investor.suggest_what_to_buy(budget, portfolio)
    send_resp(conn, 200, Jason.encode!(%{"plans" => result}))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
