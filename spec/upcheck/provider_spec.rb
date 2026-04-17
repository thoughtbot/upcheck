# frozen_string_literal: true

RSpec.describe Upcheck::Provider do
  let(:base_url) { "https://status.test.example.com" }
  let(:status_url) { "#{base_url}/api/v2/status.json" }

  describe "#status" do
    it "returns the raw indicator string from the Statuspage response" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("status_minor.json"))

      expect(described_class.new(base_url).status).to eq("minor")
    end

    it "caches the response so it only hits the network once per provider" do
      stub_request(:get, status_url)
        .to_return(status: 200, body: Fixtures.read("status_operational.json"))

      provider = described_class.new(base_url)
      provider.status
      provider.status

      expect(WebMock).to have_requested(:get, status_url).once
    end
  end

  describe "query methods" do
    it "operational? is true when indicator is none" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("status_operational.json"))
      expect(described_class.new(base_url).operational?).to be(true)
    end

    it "operational? is false when there is any incident" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("status_minor.json"))
      expect(described_class.new(base_url).operational?).to be(false)
    end

    it "degraded? is true only for minor indicator" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("status_minor.json"))
      expect(described_class.new(base_url).degraded?).to be(true)
    end

    it "major_outage? is true for major or critical" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("status_critical.json"))
      expect(described_class.new(base_url).major_outage?).to be(true)
    end

    it "maintenance? is true only for maintenance indicator" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("status_maintenance.json"))
      provider = described_class.new(base_url)

      expect(provider.maintenance?).to be(true)
      expect(provider.operational?).to be(false)
      expect(provider.degraded?).to be(false)
      expect(provider.major_outage?).to be(false)
    end
  end

  describe "#description" do
    it "returns the human-readable description from the status endpoint" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("status_operational.json"))

      expect(described_class.new(base_url).description).to eq("All Systems Operational")
    end
  end
end
