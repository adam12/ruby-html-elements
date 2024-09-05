# frozen-string-literal: true

# Scanner which parses HTML using gsub!
class ReScanner
  TAG = %r{
    <
      \s* # Ignore leading whitespace
      ([a-zA-Z0-9]+:[a-zA-Z0-9]+) # Tag name
      ([^>]*?)  # Attributes
      \s* # Ignore trailing whitespace
    >
      (.*?) # All content
    </
      \1 # Closing tag
    >
  }mx

  SELF_CLOSING_TAG = %r{
    <
      \s* # Ignore leading whitespace
      ([a-zA-Z0-9]+:[a-zA-Z0-9]+) # Tag name
      ([^>]*?)  # Attributes
      \s* # Ignore trailing whitespace
    />
  }mx

  ATTRIBUTE = /
    ([^=]+)     # Attribute name
    =           # Literal equals sign
    "([^"]*)"   # Attribute value
  /mx

  def initialize(string)
    @string = string.dup
    @self_closed_tag_template = "<%%= render \"%{component_name}\", locals: { %{merged_attrs} } %%>"
    @tag_template = "<%%= render \"%{component_name}\", locals: { \"content\" => \"%{content}\", %{merged_attrs} } %%>\n"
  end

  def scan
    @string.gsub!(SELF_CLOSING_TAG) do |match|
      component_name = $1
      attributes = $2

      attrs = attributes.scan(ATTRIBUTE).each_with_object({}) do |(key, value), attrs|
        attrs[key.strip] = value.strip
      end

      merged_attrs = attrs.map { |k, v| "#{k.inspect} => #{v.inspect}" }.join(" ")

      format(@self_closed_tag_template, {
        component_name: component_name,
        merged_attrs: merged_attrs
      })
    end

    @string.gsub!(TAG) do |match|
      component_name = $1
      attributes = $2
      content = $3.to_s

      attrs = attributes.scan(ATTRIBUTE).each_with_object({}) do |(key, value), attrs|
        attrs[key.strip] = value.strip
      end

      merged_attrs = attrs.map { |k, v| "#{k.inspect} => #{v.inspect}" }.join(" ")

      format(@tag_template, {
        component_name: component_name,
        merged_attrs: merged_attrs,
        content: content.strip.gsub(/\n/, '\n')
      }) + "\n"
    end
 
    @string
  end
end
