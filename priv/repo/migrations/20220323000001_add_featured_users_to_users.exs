defmodule Pleroma.Repo.Migrations.AddFeaturedUsersToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:featured_users, {:array, :string}, default: [], null: false)
    end
  end

  def down do
    alter table(:users) do
      remove(:featured_users)
    end
  end
end
