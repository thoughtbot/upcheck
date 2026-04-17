# frozen_string_literal: true

RSpec.describe Upcheck::Provider do
  def adapter(status: "none", description: "All Systems Operational",
    components: [], incidents: [], scheduled_maintenances: [])
    instance_double(
      Upcheck::Adapters::Statuspage,
      status: status,
      description: description,
      components: components,
      incidents: incidents,
      scheduled_maintenances: scheduled_maintenances
    )
  end

  describe "#status" do
    it "delegates to the adapter" do
      expect(described_class.new(adapter(status: "minor")).status).to eq("minor")
    end
  end

  describe "#description" do
    it "delegates to the adapter" do
      provider = described_class.new(adapter(description: "All Systems Operational"))

      expect(provider.description).to eq("All Systems Operational")
    end
  end

  describe "query methods" do
    it "operational? is true when the adapter reports none" do
      expect(described_class.new(adapter(status: "none")).operational?).to be(true)
    end

    it "operational? is false for any incident" do
      expect(described_class.new(adapter(status: "minor")).operational?).to be(false)
    end

    it "degraded? is true only for minor" do
      expect(described_class.new(adapter(status: "minor")).degraded?).to be(true)
      expect(described_class.new(adapter(status: "major")).degraded?).to be(false)
    end

    it "major_outage? is true for major or critical" do
      expect(described_class.new(adapter(status: "major")).major_outage?).to be(true)
      expect(described_class.new(adapter(status: "critical")).major_outage?).to be(true)
      expect(described_class.new(adapter(status: "minor")).major_outage?).to be(false)
    end

    it "maintenance? is true only for maintenance" do
      provider = described_class.new(adapter(status: "maintenance"))

      expect(provider.maintenance?).to be(true)
      expect(provider.operational?).to be(false)
      expect(provider.degraded?).to be(false)
      expect(provider.major_outage?).to be(false)
    end
  end

  describe "delegated collections" do
    it "returns the adapter's components, incidents, and scheduled maintenances" do
      components = [double("component")]
      incidents = [double("incident")]
      maintenances = [double("scheduled_maintenance")]
      provider = described_class.new(
        adapter(components: components, incidents: incidents, scheduled_maintenances: maintenances)
      )

      expect(provider.components).to eq(components)
      expect(provider.incidents).to eq(incidents)
      expect(provider.scheduled_maintenances).to eq(maintenances)
    end
  end

  describe "#component" do
    it "finds a component by name from the adapter's components list" do
      api = double("component", name: "API")
      web = double("component", name: "Web")
      provider = described_class.new(adapter(components: [api, web]))

      expect(provider.component("Web")).to eq(web)
    end

    it "returns nil when no component matches" do
      provider = described_class.new(adapter(components: [double("component", name: "API")]))

      expect(provider.component("Missing")).to be_nil
    end
  end
end
