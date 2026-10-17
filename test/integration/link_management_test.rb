require "test_helper"

class LinkManagementTest < ActionDispatch::IntegrationTest
  setup do
    Link.destroy_all
    sign_in_as(users(:one))
  end

  test "new and edit forms expose the body field" do
    get new_link_path
    assert_select "textarea[name='link[body]']"

    link = Link.create!(title: "Existing link", url: "example.com")
    get edit_link_path(link)
    assert_select "textarea[name='link[body]']"
  end

  test "create and update persist the body" do
    post links_path, params: { link: { title: "New link", url: "example.com", body: "Description" } }
    link = Link.order(:id).last
    assert_equal "Description", link.body

    patch link_path(link), params: { link: { body: "Updated description" } }
    assert_equal "Updated description", link.reload.body
  end
end
