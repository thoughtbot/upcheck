# frozen_string_literal: true

require "json"
require "pathname"

module Fixtures
  ROOT = Pathname.new(File.expand_path("../fixtures", __dir__))

  extend self

  def read(name)
    (ROOT / name).read
  end

  def json(name)
    JSON.parse(read(name))
  end
end
