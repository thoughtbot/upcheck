# frozen_string_literal: true

RSpec.describe Upcheck::HTTPClient do
  let(:url) { "https://status.example.com/api/v2/status.json" }

  describe "#get_json" do
    it "returns parsed JSON on a 200 response" do
      stub_request(:get, url).to_return(
        status: 200,
        headers: {"Content-Type" => "application/json"},
        body: '{"status": {"indicator": "none"}}'
      )

      result = described_class.new.get_json(url)

      expect(result).to eq("status" => {"indicator" => "none"})
    end

    it "sends a User-Agent header identifying the gem" do
      stub_request(:get, url)
        .with(headers: {"User-Agent" => /Upcheck/})
        .to_return(status: 200, body: "{}")

      described_class.new.get_json(url)

      expect(WebMock).to have_requested(:get, url)
        .with(headers: {"User-Agent" => /Upcheck\/#{Regexp.escape(Upcheck::VERSION)}/o})
    end

    it "raises Upcheck::TimeoutError when the request times out" do
      stub_request(:get, url).to_timeout

      expect {
        described_class.new.get_json(url)
      }.to raise_error(Upcheck::TimeoutError, /timed out/i)
    end

    it "raises Upcheck::HTTPError on a 500 response" do
      stub_request(:get, url).to_return(status: 500, body: "boom")

      expect {
        described_class.new.get_json(url)
      }.to raise_error(Upcheck::HTTPError, /500/)
    end

    it "raises Upcheck::HTTPError on a 404 response" do
      stub_request(:get, url).to_return(status: 404, body: "not found")

      expect {
        described_class.new.get_json(url)
      }.to raise_error(Upcheck::HTTPError, /404/)
    end

    it "raises Upcheck::ParseError when the body is not valid JSON" do
      stub_request(:get, url).to_return(status: 200, body: "not-json")

      expect {
        described_class.new.get_json(url)
      }.to raise_error(Upcheck::ParseError)
    end

    it "raises Upcheck::ConnectionError when the host is unreachable" do
      stub_request(:get, url).to_raise(SocketError.new("getaddrinfo: nodename nor servname"))

      expect {
        described_class.new.get_json(url)
      }.to raise_error(Upcheck::ConnectionError)
    end

    it "applies the configured http_timeout to Net::HTTP" do
      Upcheck.configure { |c| c.http_timeout = 7 }
      stub_request(:get, url).to_return(status: 200, body: "{}")

      captured_timeouts = []
      allow(Net::HTTP).to receive(:start).and_wrap_original do |original, *args, **kwargs, &block|
        captured_timeouts << [kwargs[:open_timeout], kwargs[:read_timeout]]
        original.call(*args, **kwargs, &block)
      end

      described_class.new.get_json(url)

      expect(captured_timeouts).to eq([[7, 7]])
    end

    it "follows HTTPS redirects" do
      final_url = "https://status.redirected.com/api/v2/status.json"
      stub_request(:get, url).to_return(
        status: 301,
        headers: {"Location" => final_url}
      )
      stub_request(:get, final_url).to_return(
        status: 200,
        body: '{"ok": true}'
      )

      result = described_class.new.get_json(url)

      expect(result).to eq("ok" => true)
    end

    it "raises Upcheck::HTTPError when a redirect is missing a Location header" do
      stub_request(:get, url).to_return(status: 302, headers: {})

      expect {
        described_class.new.get_json(url)
      }.to raise_error(Upcheck::HTTPError, /missing Location header/i)
    end

    it "raises Upcheck::HTTPError after too many redirects" do
      stub_request(:get, url).to_return(
        status: 301,
        headers: {"Location" => url}
      )

      expect {
        described_class.new.get_json(url)
      }.to raise_error(Upcheck::HTTPError, /redirect/i)
    end
  end
end
