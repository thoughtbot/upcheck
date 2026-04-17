# frozen_string_literal: true

RSpec.describe "Provider registry integration" do
  it "resolves built-in providers to their Statuspage URLs" do
    stub_request(:get, "https://status.claude.com/api/v2/status.json")
      .to_return(status: 200, body: Fixtures.read("statuspage/status_operational.json"))

    expect(Upcheck.for(:anthropic).operational?).to be(true)
  end

  it "ships an entry for each of the required built-in providers" do
    required = %i[anthropic openai github twilio datadog rubygems]

    required.each do |name|
      expect(Upcheck::Registry::BUILT_IN).to have_key(name),
        "expected :#{name} to be in the built-in registry"
    end
  end

  it "allows users to override a built-in base URL with a custom registration" do
    register_test_provider(:anthropic, "https://my-mirror.example.com")
    stub_statuspage("status.json", fixture: "status_operational.json",
      base_url: "https://my-mirror.example.com")

    expect(Upcheck.for(:anthropic).operational?).to be(true)
  end

  it "accepts a fully custom provider registered at runtime" do
    register_test_provider(:my_saas, "https://status.my-saas.example.com")
    stub_statuspage("status.json", fixture: "status_operational.json",
      base_url: "https://status.my-saas.example.com")

    expect(Upcheck.for(:my_saas).operational?).to be(true)
  end
end
