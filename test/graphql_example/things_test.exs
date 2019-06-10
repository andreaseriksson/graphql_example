defmodule GraphqlExample.ThingsTest do
  use GraphqlExample.DataCase
  import GraphqlExample.Fixtures

  alias GraphqlExample.Things
  alias GraphqlExample.Things.{Thing, Feature}

  describe "things" do
    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_things/0 returns all things" do
      user = user_fixture()
      thing = thing_fixture(user)
      assert [%Thing{id: id}] = Things.list_things(user)
      assert id == thing.id
    end

    test "get_thing!/1 returns the thing with given id" do
      user = user_fixture()
      thing = thing_fixture(user)
      assert %Thing{id: id} = Things.get_thing!(user, thing.id)
      assert id == thing.id
    end

    test "create_thing/1 with valid data creates a thing" do
      user = user_fixture()
      assert {:ok, %Thing{} = thing} = Things.create_thing(user, @valid_attrs)
      assert thing.name == "some name"
    end

    test "create_thing/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Things.create_thing(user, @invalid_attrs)
    end

    test "update_thing/2 with valid data updates the thing" do
      thing = thing_fixture()
      assert {:ok, %Thing{} = thing} = Things.update_thing(thing, @update_attrs)
      assert thing.name == "some updated name"
    end

    test "update_thing/2 with invalid data returns error changeset" do
      user = user_fixture()
      thing = thing_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Things.update_thing(thing, @invalid_attrs)
      assert %Thing{} = Things.get_thing!(user, thing.id)
    end

    test "delete_thing/1 deletes the thing" do
      user = user_fixture()
      thing = thing_fixture(user)
      assert {:ok, %Thing{}} = Things.delete_thing(thing)
      assert_raise Ecto.NoResultsError, fn -> Things.get_thing!(user, thing.id) end
    end

    test "change_thing/1 returns a thing changeset" do
      user = user_fixture()
      thing = thing_fixture(user)
      assert %Ecto.Changeset{} = Things.change_thing(thing)
    end
  end

  describe "features" do
    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_features/0 returns all features" do
      thing = thing_fixture()
      feature = feature_fixture(thing)
      assert [%Feature{id: id}] = Things.list_features(thing)
      assert id == feature.id
    end

    test "get_feature!/1 returns the feature with given id" do
      thing = thing_fixture()
      feature = feature_fixture(thing)
      assert %Feature{id: id} = Things.get_feature!(thing, feature.id)
      assert id == feature.id
    end

    test "create_feature/1 with valid data creates a feature" do
      thing = thing_fixture()
      assert {:ok, %Feature{} = feature} = Things.create_feature(thing, @valid_attrs)
      assert feature.name == "some name"
    end

    test "create_feature/1 with invalid data returns error changeset" do
      thing = thing_fixture()
      assert {:error, %Ecto.Changeset{}} = Things.create_feature(thing, @invalid_attrs)
    end

    test "update_feature/2 with valid data updates the feature" do
      feature = feature_fixture()
      assert {:ok, %Feature{} = feature} = Things.update_feature(feature, @update_attrs)
      assert feature.name == "some updated name"
    end

    test "update_feature/2 with invalid data returns error changeset" do
      thing = thing_fixture()
      feature = feature_fixture(thing)
      assert {:error, %Ecto.Changeset{}} = Things.update_feature(feature, @invalid_attrs)
      assert %Feature{} = Things.get_feature!(thing, feature.id)
    end

    test "delete_feature/1 deletes the feature" do
      thing = thing_fixture()
      feature = feature_fixture(thing)
      assert {:ok, %Feature{}} = Things.delete_feature(feature)
      assert_raise Ecto.NoResultsError, fn -> Things.get_feature!(thing, feature.id) end
    end

    test "change_feature/1 returns a feature changeset" do
      feature = feature_fixture()
      assert %Ecto.Changeset{} = Things.change_feature(feature)
    end
  end
end
