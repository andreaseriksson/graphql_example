defmodule GraphqlExampleWeb.Schema.ThingTypes do
  use Absinthe.Schema.Notation

  alias GraphqlExampleWeb.Resolvers

  @desc "A thing"
  object :thing do
    field :name, :string
    field :id, :id
  end

  object :get_things do
    @desc """
    Get a list of things
    """

    field :things, list_of(:thing) do
      resolve(&Resolvers.Things.list_things/2)
    end
  end

  object :get_thing do
    @desc """
    Get a specific thing
    """

    field :thing, :thing do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Things.get_thing/2)
    end
  end

  object :create_thing do
    @desc """
    Create a thing
    """

    @desc "Create a thing"
    field :create_thing, :thing do
      arg(:name, :string)

      resolve(&Resolvers.Things.create_thing/2)
    end
  end

  object :update_thing do
    @desc """
    Update a thing
    """

    @desc "Update a thing"
    field :update_thing, :thing do
      arg(:id, non_null(:id))
      arg(:name, :string)

      resolve(&Resolvers.Things.update_thing/2)
    end
  end

  object :delete_thing do
    @desc """
    Delete a specific thing
    """

    field :delete_thing, :thing do
      arg(:id, non_null(:id))

      resolve(&Resolvers.Things.delete_thing/2)
    end
  end
end
