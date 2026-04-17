# frozen_string_literal: true

RSpec.describe Upcheck::Registry do
  describe ".resolve" do
    it "returns the adapter built by the user's factory" do
      adapter = double("adapter")
      Upcheck.configure { |config| config.register_provider(:custom) { adapter } }

      expect(described_class.resolve(:custom)).to eq(adapter)
    end

    it "accepts string names" do
      adapter = double("adapter")
      Upcheck.configure { |config| config.register_provider(:custom) { adapter } }

      expect(described_class.resolve("custom")).to eq(adapter)
    end

    it "raises UnknownProviderError when the provider is not registered" do
      expect { described_class.resolve(:nope) }.to raise_error(Upcheck::UnknownProviderError)
    end

    it "returns a fresh adapter instance on each call for built-in providers" do
      first = described_class.resolve(:anthropic)
      second = described_class.resolve(:anthropic)

      expect(first).to be_a(Upcheck::Adapters::Statuspage)
      expect(first).not_to equal(second)
    end
  end
end
