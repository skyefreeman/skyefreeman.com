class AuthenticatedDirectUploadsController < ActiveStorage::DirectUploadsController
  include Authentication
end
