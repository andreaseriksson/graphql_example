defmodule GraphqlExampleWeb.Schema.GetThingsTest do
  use GraphqlExampleWeb.ConnCase, async: false
  import GraphqlExample.GraphqlTestHelpers

  defp get_response(conn, args) do
    conn
    |> post("/api", args)
  end

  @query """
    query {
      things {
        id
      }
    }
  """

  defp get_post_args do
    %{
      query: @query
    }
  end

  describe "when not logged in" do
    setup [:user_with_invalid_jwt, :with_thing]

    test "get things with invalid credentials", %{conn: conn} do
      args = get_post_args()

      response =
        conn
        |> get_response(args)

      assert %{
               "data" => %{"things" => nil},
               "errors" => [
                 %{
                   "locations" => [_],
                   "message" => "Not Authorized",
                   "path" => ["things"]
                 }
               ]
             } = json_response(response, 200)
    end
  end

  describe "when logged in" do
    setup [:user_with_valid_jwt, :with_thing]

    test "get things with valid credentials", %{conn: conn, jwt: jwt} do
      args = get_post_args()

      response =
        conn
        |> put_req_header("authorization", jwt)
        |> get_response(args)

      assert %{
               "data" => %{
                 "things" => [%{"id" => _}]
               }
             } = json_response(response, 200)
    end
  end
end
