# Add Authentication
Bloak::Admin::AdminController.class_eval do
  http_basic_authenticate_with(
    name: Bloak.admin_user,
    password: Bloak.admin_password,
  ) if Bloak.admin_user.present? && Bloak.admin_password.present?
end
