# frozen_string_literal: true

RSpec.describe "Page status integration" do
  before { register_test_provider }

  it "returns operational state for a healthy provider" do
    stub_statuspage("status.json", fixture: "status_operational.json")

    provider = Upcheck.for(:test)

    expect(provider.operational?).to be(true)
    expect(provider.degraded?).to be(false)
    expect(provider.major_outage?).to be(false)
    expect(provider.status).to eq(Upcheck::Provider::INDICATOR_NONE)
  end

  it "reports minor degradation" do
    stub_statuspage("status.json", fixture: "status_minor.json")

    provider = Upcheck.for(:test)

    expect(provider.operational?).to be(false)
    expect(provider.degraded?).to be(true)
    expect(provider.major_outage?).to be(false)
    expect(provider.status).to eq(Upcheck::Provider::INDICATOR_MINOR)
  end

  it "reports a major outage" do
    stub_statuspage("status.json", fixture: "status_major.json")

    provider = Upcheck.for(:test)

    expect(provider.operational?).to be(false)
    expect(provider.degraded?).to be(false)
    expect(provider.major_outage?).to be(true)
    expect(provider.status).to eq(Upcheck::Provider::INDICATOR_MAJOR)
  end

  it "reports a critical outage as a major outage" do
    stub_statuspage("status.json", fixture: "status_critical.json")

    provider = Upcheck.for(:test)

    expect(provider.major_outage?).to be(true)
    expect(provider.status).to eq(Upcheck::Provider::INDICATOR_CRITICAL)
  end

  it "raises UnknownProviderError when the provider is not registered" do
    expect {
      Upcheck.for(:does_not_exist)
    }.to raise_error(Upcheck::UnknownProviderError, /does_not_exist/)
  end
end
