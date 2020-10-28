defmodule PlanningPoker.PlanningTest do
  use PlanningPoker.DataCase

  alias PlanningPoker.Planning

  describe "tables" do
    alias PlanningPoker.Planning.Table

    @valid_attrs %{table_name: "some table_name"}
    @update_attrs %{table_name: "some updated table_name"}
    @invalid_attrs %{table_name: nil}

    def table_fixture(attrs \\ %{}) do
      {:ok, table} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Planning.create_table()

      table
    end

    test "list_tables/0 returns all tables" do
      table = table_fixture()
      assert Planning.list_tables() == [table]
    end

    test "get_table!/1 returns the table with given id" do
      table = table_fixture()
      assert Planning.get_table!(table.id) == table
    end

    test "create_table/1 with valid data creates a table" do
      assert {:ok, %Table{} = table} = Planning.create_table(@valid_attrs)
      assert table.table_name == "some table_name"
    end

    test "create_table/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Planning.create_table(@invalid_attrs)
    end

    test "update_table/2 with valid data updates the table" do
      table = table_fixture()
      assert {:ok, %Table{} = table} = Planning.update_table(table, @update_attrs)
      assert table.table_name == "some updated table_name"
    end

    test "update_table/2 with invalid data returns error changeset" do
      table = table_fixture()
      assert {:error, %Ecto.Changeset{}} = Planning.update_table(table, @invalid_attrs)
      assert table == Planning.get_table!(table.id)
    end

    test "delete_table/1 deletes the table" do
      table = table_fixture()
      assert {:ok, %Table{}} = Planning.delete_table(table)
      assert_raise Ecto.NoResultsError, fn -> Planning.get_table!(table.id) end
    end

    test "change_table/1 returns a table changeset" do
      table = table_fixture()
      assert %Ecto.Changeset{} = Planning.change_table(table)
    end
  end
end
