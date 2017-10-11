defmodule PhoenixChat.OrganizationView do
  use PhoenixChat.Web, :view

  def render("index.json", %{organizations: organizations}) do
    %{data: render_many(organizations, PhoenixChat.OrganizationView, "organization.json")}
  end

  def render("show.json", %{organization: organization}) do
    %{data: render_one(organization, PhoenixChat.OrganizationView, "organization.json")}
  end

  def render("organization.json", %{organization: organization}) do
    %{id: organization.id,
      public_key: organization.public_key,
      website: organization.website,
      owner_id: organization.owner_id}
  end
end
