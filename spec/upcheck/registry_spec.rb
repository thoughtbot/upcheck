# frozen_string_literal: true

RSpec.describe Upcheck::Registry do
  describe ".resolve" do
    it "returns the URL for a user-registered provider" do
      Upcheck.configure do |config|
        config.register_provider(:custom, "https://status.custom.example.com")
      end

      expect(described_class.resolve(:custom)).to eq("https://status.custom.example.com")
    end

    it "raises UnknownProviderError when the provider is not registered" do
      expect {
        described_class.resolve(:nope)
      }.to raise_error(Upcheck::UnknownProviderError)
    end

    it "accepts string names" do
      Upcheck.configure do |config|
        config.register_provider(:custom, "https://status.custom.example.com")
      end

      expect(described_class.resolve("custom")).to eq("https://status.custom.example.com")
    end
  end
end
