# frozen_string_literal: true

RSpec.describe "Components integration" do
  before do
    register_test_provider
    stub_statuspage("components.json", fixture: "components.json")
  end

  it "lists every component returned by the API" do
    names = Upcheck.for(:test).components.map(&:name)

    expect(names).to contain_exactly("API", "Dashboard", "Webhooks", "File Uploads")
  end

  it "looks up a component by name and exposes its status" do
    provider = Upcheck.for(:test)

    api = provider.component("API")
    dashboard = provider.component("Dashboard")
    webhooks = provider.component("Webhooks")
    uploads = provider.component("File Uploads")

    expect(api.status).to eq(Upcheck::Component::STATUS_OPERATIONAL)
    expect(api.operational?).to be(true)

    expect(dashboard.status).to eq(Upcheck::Component::STATUS_DEGRADED_PERFORMANCE)
    expect(dashboard.degraded?).to be(true)
    expect(dashboard.operational?).to be(false)

    expect(webhooks.status).to eq(Upcheck::Component::STATUS_MAJOR_OUTAGE)
    expect(webhooks.major_outage?).to be(true)

    expect(uploads.status).to eq(Upcheck::Component::STATUS_PARTIAL_OUTAGE)
    expect(uploads.partial_outage?).to be(true)
  end

  it "returns nil when the component is not found" do
    expect(Upcheck.for(:test).component("Nope")).to be_nil
  end
end
