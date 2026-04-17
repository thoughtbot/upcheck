# frozen_string_literal: true

RSpec.describe Upcheck::Configuration do
  describe "defaults" do
    it "has a default http_timeout of 5 seconds" do
      config = Upcheck::Configuration.new

      expect(config.http_timeout).to eq(5)
    end

    it "seeds the built-in Statuspage providers" do
      config = Upcheck::Configuration.new

      expect(config.providers).to include(:anthropic, :openai, :github)
    end
  end

  describe "#register_provider" do
    it "stores the factory block under the given symbol" do
      config = Upcheck::Configuration.new
      adapter = double("adapter")

      config.register_provider(:my_service) { adapter }

      expect(config.providers[:my_service].call).to eq(adapter)
    end

    it "coerces string names to symbols" do
      config = Upcheck::Configuration.new
      adapter = double("adapter")

      config.register_provider("my_service") { adapter }

      expect(config.providers[:my_service].call).to eq(adapter)
    end

    it "raises ArgumentError when no block is given" do
      config = Upcheck::Configuration.new

      expect { config.register_provider(:oops) }.to raise_error(ArgumentError)
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
