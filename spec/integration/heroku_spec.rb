# frozen_string_literal: true

RSpec.describe "Heroku provider integration" do
  it "reports operational when all Heroku systems are green" do
    stub_heroku("current_status_operational.json")

    expect(Upcheck.for(:heroku).operational?).to be(true)
  end

  it "reports maintenance when a Heroku system is blue" do
    stub_heroku("current_status_maintenance.json")

    provider = Upcheck.for(:heroku)

    expect(provider.maintenance?).to be(true)
    expect(provider.operational?).to be(false)
  end
end
