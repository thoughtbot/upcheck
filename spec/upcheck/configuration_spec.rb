# frozen_string_literal: true

RSpec.describe Upcheck::Configuration do
  describe "defaults" do
    it "has a default http_timeout of 5 seconds" do
      config = Upcheck::Configuration.new

      expect(config.http_timeout).to eq(5)
    end

    it "starts with no custom providers registered" do
      config = Upcheck::Configuration.new

      expect(config.providers).to eq({})
    end
  end

  describe "#register_provider" do
    it "registers a provider under the given symbol" do
      config = Upcheck::Configuration.new
      config.register_provider(:my_service, "https://status.my-service.com")

      expect(config.providers[:my_service]).to eq("https://status.my-service.com")
    end

    it "coerces string names to symbols" do
      config = Upcheck::Configuration.new
      config.register_provider("my_service", "https://status.my-service.com")

      expect(config.providers[:my_service]).to eq("https://status.my-service.com")
    end
  end
end

RSpec.describe Upcheck do
  describe ".configure" do
    it "yields the configuration so users can override defaults" do
      Upcheck.configure do |config|
        config.http_timeout = 12
      end

      expect(Upcheck.configuration.http_timeout).to eq(12)
    end
  end

  describe ".reset!" do
    it "resets the configuration back to defaults" do
      Upcheck.configure { |c| c.http_timeout = 99 }

      Upcheck.reset!

      expect(Upcheck.configuration.http_timeout).to eq(5)
    end
  end
end
