# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"

ActiveSupport::TestCase.fixture_paths = [File.expand_path("fixtures", __dir__)]
ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures/files", __dir__)
ActiveSupport::TestCase.fixtures(:all)

class ActiveSupport::TestCase
  private

  def attach_test_image(record, attachment_name = :cover_image)
    record.send(attachment_name).attach(
      io: File.open(file_fixture("test.png")),
      filename: "test.png",
      content_type: "image/png"
    )
  end

  def admin_credentials
    ActionController::HttpAuthentication::Basic.encode_credentials("admin", "password")
  end
end
