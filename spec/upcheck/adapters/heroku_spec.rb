# frozen_string_literal: true

RSpec.describe Upcheck::Adapters::Heroku do
  let(:url) { described_class::URL }

  describe "the provider adapter contract" do
    before { stub_heroku("current_status_operational.json") }

    let(:adapter) { described_class.new }

    it_behaves_like "a provider adapter"
  end

  describe "caching" do
    it "hits the network once per adapter instance regardless of calls" do
      stub_heroku("current_status_with_incidents.json")

      adapter = described_class.new
      adapter.status
      adapter.description
      adapter.components
      adapter.incidents
      adapter.scheduled_maintenances

      expect(WebMock).to have_requested(:get, url).once
    end
  end

  describe "#status" do
    it "returns 'none' when all systems are green" do
      stub_heroku("current_status_operational.json")

      expect(described_class.new.status).to eq("none")
    end

    it "returns 'major' when a system is red" do
      stub_heroku("current_status_major.json")

      expect(described_class.new.status).to eq("major")
    end

    it "returns 'minor' when the worst system is yellow" do
      stub_heroku("current_status_minor.json")

      expect(described_class.new.status).to eq("minor")
    end

    it "returns 'maintenance' when the worst system is blue" do
      stub_heroku("current_status_maintenance.json")

      expect(described_class.new.status).to eq("maintenance")
    end

    it "ranks degradation above maintenance when both are present" do
      stub_heroku_body({
        "status" => [
          {"system" => "Apps", "status" => "blue"},
          {"system" => "Data", "status" => "yellow"}
        ],
        "incidents" => [], "scheduled" => []
      })

      expect(described_class.new.status).to eq("minor")
    end

    it "returns 'none' when Heroku reports no systems" do
      stub_heroku_body({"status" => [], "incidents" => [], "scheduled" => []})

      expect(described_class.new.status).to eq("none")
    end

    it "raises Upcheck::ParseError on an unrecognized status color" do
      stub_heroku_body({
        "status" => [{"system" => "Apps", "status" => "purple"}],
        "incidents" => [], "scheduled" => []
      })

      expect { described_class.new.status }
        .to raise_error(Upcheck::ParseError, /purple/)
    end
  end

  describe "#description" do
    it "synthesizes an operational message when status is 'none'" do
      stub_heroku("current_status_operational.json")

      expect(described_class.new.description).to eq("All systems operational")
    end

    it "synthesizes a degradation message when status is 'minor'" do
      stub_heroku("current_status_minor.json")

      expect(described_class.new.description).to eq("Some systems experiencing degradation")
    end

    it "synthesizes a disruption message when status is 'major'" do
      stub_heroku("current_status_major.json")

      expect(described_class.new.description).to eq("Major service disruption")
    end

    it "synthesizes a maintenance message when status is 'maintenance'" do
      stub_heroku("current_status_maintenance.json")

      expect(described_class.new.description).to eq("Systems under maintenance")
    end
  end

  describe "#components" do
    it "returns one Upcheck::Component per Heroku system, preserving order" do
      stub_heroku("current_status_operational.json")

      components = described_class.new.components

      expect(components).to all(be_a(Upcheck::Component))
      expect(components.map(&:name)).to eq(["Apps", "Data", "Tools"])
    end

    it "maps Heroku colors to Upcheck::Component status values" do
      stub_heroku("current_status_minor.json")

      components = described_class.new.components

      expect(components.find { |c| c.name == "Apps" }.status).to eq("degraded_performance")
      expect(components.find { |c| c.name == "Apps" }.degraded?).to be(true)
      expect(components.find { |c| c.name == "Data" }.operational?).to be(true)
    end

    it "maps blue systems to under_maintenance components" do
      stub_heroku("current_status_maintenance.json")

      apps = described_class.new.components.find { |c| c.name == "Apps" }

      expect(apps.status).to eq("under_maintenance")
      expect(apps.maintenance?).to be(true)
    end

    it "raises Upcheck::ParseError on an unrecognized system color" do
      stub_heroku_body({
        "status" => [{"system" => "Apps", "status" => "purple"}],
        "incidents" => [], "scheduled" => []
      })

      expect { described_class.new.components }
        .to raise_error(Upcheck::ParseError, /purple/)
    end
  end

  describe "#incidents" do
    it "returns an empty array when there are no active incidents" do
      stub_heroku("current_status_operational.json")

      expect(described_class.new.incidents).to eq([])
    end

    it "builds Upcheck::Incident instances with Heroku field renames" do
      stub_heroku("current_status_with_incidents.json")

      incidents = described_class.new.incidents

      expect(incidents).to all(be_a(Upcheck::Incident))
      expect(incidents.size).to eq(1)
      incident = incidents.first
      expect(incident.id).to eq(2999)
      expect(incident.name).to eq("Heroku Service Disruption")
      expect(incident.status).to eq("investigating")
      expect(incident.created_at).to eq("2026-04-17T10:00:00.000Z")
      expect(incident.resolved_at).to be_nil
    end

    it "translates incident updates from Heroku field names to Upcheck::Incident::Update attributes" do
      stub_heroku("current_status_with_incidents.json")

      updates = described_class.new.incidents.first.updates

      expect(updates).to all(be_a(Upcheck::Incident::Update))
      expect(updates.size).to eq(2)
      expect(updates.first.status).to eq("investigating")
      expect(updates.first.body).to eq("Heroku engineers are investigating.")
      expect(updates.first.created_at).to eq("2026-04-17T10:00:00.000Z")
    end
  end

  describe "#scheduled_maintenances" do
    it "returns an empty array when there are no scheduled maintenances" do
      stub_heroku("current_status_operational.json")

      expect(described_class.new.scheduled_maintenances).to eq([])
    end

    it "builds Upcheck::Incident instances from the scheduled array" do
      stub_heroku("current_status_with_scheduled.json")

      scheduled = described_class.new.scheduled_maintenances

      expect(scheduled).to all(be_a(Upcheck::Incident))
      expect(scheduled.size).to eq(1)
      expect(scheduled.first.name).to eq("Heroku Platform Maintenance")
      expect(scheduled.first.status).to eq("scheduled")
    end
  end
end
