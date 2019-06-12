defmodule GraphqlExampleWeb.Schema.DeleteThingTest do
  use GraphqlExampleWeb.ConnCase, async: false
  import GraphqlExample.GraphqlTestHelpers

  defp get_response(conn, args) do
    conn
    |> post("/api", args)
  end

  @query """
    mutation ($id: ID!) {
      thing: deleteThing(id: $id) {
        id
        name
      }
    }
  """

  defp get_post_args(args) do
    %{
      query: @query,
      variables: %{
        "id" => args[:id]
      }
    }
  end

  describe "when not logged in" do
    setup [:user_with_invalid_jwt, :with_thing]

    test "delete thing with invalid credentials", %{conn: conn, thing: thing} do
      %{id: id} = thing
      args = get_post_args(%{id: id})

      response =
        conn
        |> get_response(args)

      assert %{
               "data" => %{"thing" => nil},
               "errors" => [
                 %{
                   "message" => "Not Authorized"
                 }
               ]
             } = json_response(response, 200)
    end
  end

  describe "when logged in" do
    setup [:user_with_valid_jwt, :with_thing]

    test "delete thing with valid credentials", %{
      conn: conn,
      jwt: jwt,
      thing: thing,
      user: user
    } do
      %{id: id} = thing
      args = get_post_args(%{id: id})

      response =
        conn
        |> put_req_header("authorization", jwt)
        |> get_response(args)

      assert %{
               "data" => %{
                 "thing" => %{"id" => thing_id, "name" => "" <> _}
               }
             } = json_response(response, 200)

      assert thing_id == "#{id}"
      assert GraphqlExample.Things.list_things(user) == []
    end

    test "delete thing when id is wrong", %{conn: conn, jwt: jwt, user: user} do
      args = get_post_args(%{id: 0})

      response =
        conn
        |> put_req_header("authorization", jwt)
        |> get_response(args)

      assert %{
               "data" => %{
                 "thing" => nil
               }
             } = json_response(response, 200)

      assert [_] = GraphqlExample.Things.list_things(user)
    end
  end
end
