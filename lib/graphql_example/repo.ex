defmodule GraphqlExample.Repo do
  use Ecto.Repo,
    otp_app: :graphql_example,
    adapter: Ecto.Adapters.Postgres
end
