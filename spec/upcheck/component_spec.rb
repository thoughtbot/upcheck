# frozen_string_literal: true

RSpec.describe Upcheck::Component do
  describe "#name and #status" do
    it "exposes the raw name and status from the payload" do
      component = described_class.new("name" => "API", "status" => "operational")

      expect(component.name).to eq("API")
      expect(component.status).to eq("operational")
    end
  end

  describe "query methods" do
    it "operational? is true only when status is 'operational'" do
      expect(described_class.new("status" => "operational").operational?).to be(true)
      expect(described_class.new("status" => "degraded_performance").operational?).to be(false)
    end

    it "degraded? is true only for 'degraded_performance'" do
      expect(described_class.new("status" => "degraded_performance").degraded?).to be(true)
      expect(described_class.new("status" => "operational").degraded?).to be(false)
    end

    it "partial_outage? is true only for 'partial_outage'" do
      expect(described_class.new("status" => "partial_outage").partial_outage?).to be(true)
      expect(described_class.new("status" => "major_outage").partial_outage?).to be(false)
    end

    it "major_outage? is true only for 'major_outage'" do
      expect(described_class.new("status" => "major_outage").major_outage?).to be(true)
      expect(described_class.new("status" => "partial_outage").major_outage?).to be(false)
    end
  end

  describe "#description" do
    it "exposes the description from the payload" do
      component = described_class.new(
        "name" => "API",
        "status" => "operational",
        "description" => "public API"
      )

      expect(component.description).to eq("public API")
    end
  end
end
