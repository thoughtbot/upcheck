# frozen_string_literal: true

module UpcheckHelpers
  BASE_URL = "https://status.test.example.com"

  def register_test_provider(name = :test, url = BASE_URL)
    Upcheck.configure do |config|
      config.register_provider(name) { Upcheck::Adapters::Statuspage.new(url) }
    end
  end

  def stub_statuspage(path, fixture:, base_url: BASE_URL, status: 200)
    stub_request(:get, "#{base_url}/api/v2/#{path}")
      .to_return(status: status, body: Fixtures.read("statuspage/#{fixture}"))
  end

  def stub_heroku(fixture, status: 200)
    stub_request(:get, Upcheck::Adapters::Heroku::URL)
      .to_return(status: status, body: Fixtures.read("heroku/#{fixture}"))
  end

  def stub_heroku_body(payload, status: 200)
    stub_request(:get, Upcheck::Adapters::Heroku::URL)
      .to_return(status: status, body: JSON.generate(payload))
  end
end
