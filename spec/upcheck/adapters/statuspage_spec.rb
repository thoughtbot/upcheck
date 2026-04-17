# frozen_string_literal: true

RSpec.describe Upcheck::Adapters::Statuspage do
  let(:base_url) { "https://status.test.example.com" }
  let(:status_url) { "#{base_url}/api/v2/status.json" }

  describe "the provider adapter contract" do
    before do
      stub_statuspage("status.json", fixture: "status_operational.json")
      stub_statuspage("components.json", fixture: "components.json")
      stub_statuspage("incidents/unresolved.json", fixture: "incidents_unresolved.json")
      stub_statuspage("scheduled-maintenances/active.json", fixture: "scheduled_active.json")
    end

    let(:adapter) { described_class.new(base_url) }

    it_behaves_like "a provider adapter"
  end

  describe "#status" do
    it "returns the raw indicator string from the Statuspage response" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("statuspage/status_minor.json"))

      expect(described_class.new(base_url).status).to eq("minor")
    end

    it "caches the response so it only hits the network once per adapter" do
      stub_request(:get, status_url)
        .to_return(status: 200, body: Fixtures.read("statuspage/status_operational.json"))

      adapter = described_class.new(base_url)
      adapter.status
      adapter.status

      expect(WebMock).to have_requested(:get, status_url).once
    end
  end

  describe "#description" do
    it "returns the human-readable description from the status endpoint" do
      stub_request(:get, status_url).to_return(status: 200, body: Fixtures.read("statuspage/status_operational.json"))

      expect(described_class.new(base_url).description).to eq("All Systems Operational")
    end
  end
end
