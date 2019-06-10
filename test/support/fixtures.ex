defmodule GraphqlExample.Fixtures do
  alias GraphqlExample.Authentication
  alias GraphqlExample.Authentication.User
  alias GraphqlExample.Things
  alias GraphqlExample.Things.Thing

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      Enum.into(attrs, %{
        email: "some_email@example.com",
        name: "name",
        password: "password",
        password_confirmation: "password"
      })
      |> Authentication.create_user()

    user
  end

  def thing_fixture(%User{} = user, attrs) do
    attrs = Enum.into(attrs, %{name: "some name"})
    {:ok, thing} = Things.create_thing(user, attrs)

    thing
  end

  def thing_fixture(%User{} = user), do: thing_fixture(user, %{})
  def thing_fixture(attrs), do: user_fixture() |> thing_fixture(attrs)
  def thing_fixture(), do: thing_fixture(%{})

  def feature_fixture(%Thing{} = thing, attrs) do
    attrs = Enum.into(attrs, %{name: "some name"})
    {:ok, feature} = Things.create_feature(thing, attrs)

    feature
  end

  def feature_fixture(%Thing{} = thing), do: feature_fixture(thing, %{})
  def feature_fixture(attrs), do: thing_fixture() |> feature_fixture(attrs)
  def feature_fixture(), do: feature_fixture(%{})
end
