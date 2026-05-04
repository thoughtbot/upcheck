# frozen_string_literal: true

RSpec.describe "Components integration" do
  before do
    register_test_provider
    stub_statuspage("components.json", fixture: "components.json")
  end

  it "lists every component returned by the API" do
    names = Upcheck.for(:test).components.map(&:name)

    expect(names).to contain_exactly("Git Operations", "Webhooks", "Issues", "Pull Requests")
  end

  it "looks up a component by name and exposes its status" do
    provider = Upcheck.for(:test)

    git = provider.component(name: "Git Operations")
    issues = provider.component(name: "Issues")
    webhooks = provider.component(name: "Webhooks")
    pulls = provider.component(name: "Pull Requests")

    expect(git.status).to eq(Upcheck::Component::STATUS_OPERATIONAL)
    expect(git.operational?).to be(true)

    expect(issues.status).to eq(Upcheck::Component::STATUS_DEGRADED_PERFORMANCE)
    expect(issues.degraded?).to be(true)
    expect(issues.operational?).to be(false)

    expect(webhooks.status).to eq(Upcheck::Component::STATUS_MAJOR_OUTAGE)
    expect(webhooks.major_outage?).to be(true)

    expect(pulls.status).to eq(Upcheck::Component::STATUS_PARTIAL_OUTAGE)
    expect(pulls.partial_outage?).to be(true)
  end

  it "looks up a component by its stable id" do
    git = Upcheck.for(:test).component(id: "8l4ygp009s5s")

    expect(git.name).to eq("Git Operations")
    expect(git.operational?).to be(true)
  end

  it "returns nil when the component is not found" do
    expect(Upcheck.for(:test).component(name: "Nope")).to be_nil
  end
end
