User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password = "changeme"
  u.password_confirmation = "changeme"
end
