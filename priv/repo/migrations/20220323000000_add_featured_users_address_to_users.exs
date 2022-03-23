defmodule Pleroma.Repo.Migrations.AddFeaturedUsersAddressToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add(:featured_users_address, :string)
    end

    create(index(:users, [:featured_users_address]))

    execute("""

    update users set featured_users_address = concat(ap_id, '/collections/featured_users') where local = true and featured_users_address is null;

    """)
  end

  def down do
    alter table(:users) do
      remove(:featured_users_address)
    end
  end
end
