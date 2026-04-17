# frozen_string_literal: true

# Contract every provider adapter must satisfy.
#
# Including context must define `adapter` as a `let` — an adapter whose
# upstream sources are stubbed so the five methods below are callable.
RSpec.shared_examples "a provider adapter" do
  it "exposes a canonical status string" do
    expect(%w[none minor major critical maintenance]).to include(adapter.status)
  end

  it "exposes a description string" do
    expect(adapter.description).to be_a(String)
  end

  it "exposes components as Upcheck::Component instances" do
    expect(adapter.components).to all(be_a(Upcheck::Component))
  end

  it "exposes incidents as Upcheck::Incident instances" do
    expect(adapter.incidents).to all(be_a(Upcheck::Incident))
  end

  it "exposes scheduled maintenances as Upcheck::Incident instances" do
    expect(adapter.scheduled_maintenances).to all(be_a(Upcheck::Incident))
  end
end
