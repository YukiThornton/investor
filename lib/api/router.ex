defmodule Api.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: {Jason, :decode!, [[keys: :atoms]]}

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "hello")
  end

  post "/plans" do
    %{budget: budget, portfolio: portfolio} = conn.body_params
    IO.inspect(budget)
    IO.inspect(portfolio)
    result = App.Investor.suggest_what_to_buy(budget, portfolio)
    send_resp(conn, 200, Jason.encode!(%{"plans" => result}))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
