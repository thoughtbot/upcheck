# frozen_string_literal: true

module UpcheckHelpers
  BASE_URL = "https://status.test.example.com"

  def register_test_provider(name = :test, url = BASE_URL)
    Upcheck.configure { |c| c.register_provider(name, url) }
  end

  def stub_statuspage(path, fixture:, base_url: BASE_URL, status: 200)
    stub_request(:get, "#{base_url}/api/v2/#{path}")
      .to_return(status: status, body: Fixtures.read(fixture))
  end
end
