require "tilt"
require_relative "scanner"

module Tilt
  # Example of using Scanner as a parser in Tilt
  EERBTemplate = Tilt::StaticTemplate.subclass do
    Scanner.new(@data).scan
  end

  register EERBTemplate, "html"
  register_pipeline "html.erb"
end
