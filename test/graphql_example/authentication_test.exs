defmodule GraphqlExample.AuthenticationTest do
  use GraphqlExample.DataCase

  alias GraphqlExample.Authentication

  describe "users" do
    alias GraphqlExample.Authentication.User

    @valid_attrs %{
      email: "some_email@example.com",
      name: "some name",
      password: "some password",
      password_confirmation: "some password"
    }
    @update_attrs %{
      email: "some_updated_email@example.com",
      name: "some updated name",
      password: "some updated password",
      password_confirmation: "some updated password"
    }
    @invalid_attrs %{email: nil, name: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Authentication.create_user()

      user
    end

    test "authenticate_user/2 with correct password returns authenticated user" do
      user = user_fixture()

      assert {:ok, %User{id: id}} =
               Authentication.authenticate_user("some_email@example.com", "some password")

      assert id == user.id
    end

    test "authenticate_user/2 with incorrect password returns error" do
      user_fixture()

      assert {:error, "" <> _} =
               Authentication.authenticate_user("some_email@example.com", "wrong_pass")
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert [%User{id: id}] = Authentication.list_users()
      assert id == user.id
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert %User{id: id} = Authentication.get_user!(user.id)
      assert id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Authentication.create_user(@valid_attrs)
      assert user.email == "some_email@example.com"
      assert user.name == "some name"
      assert "" <> _ = user.password_hash
    end

    test "create_user/1 with existing email returns error changeset" do
      user_fixture()
      assert {:error, %Ecto.Changeset{errors: errors}} = Authentication.create_user(@valid_attrs)
      assert [{:email, _}] = errors
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Authentication.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Authentication.update_user(user, @update_attrs)
      assert user.email == "some_updated_email@example.com"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Authentication.update_user(user, @invalid_attrs)
      assert user.id == Authentication.get_user!(user.id).id
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Authentication.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Authentication.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Authentication.change_user(user)
    end
  end
end
