# frozen-string-literal: true

# Scanner which parses HTML using gsub!
class ReScanner
  TAG = %r{
    <
      \s*                                 # Ignore leading whitespace
      (?<name> [a-zA-Z0-9]+:[a-zA-Z0-9]+) # Tag name
      (?<attributes> [^>]*?)              # Attributes
      \s*                                 # Ignore trailing whitespace
    >
      (?<content> .*?)                    # All content
    </
      \g<name>                            # Closing tag
    >
  }mx

  SELF_CLOSING_TAG = %r{
    <
      \s*                                 # Ignore leading whitespace
      (?<name> [a-zA-Z0-9]+:[a-zA-Z0-9]+) # Tag name
      (?<attributes> [^>]*?)              # Attributes
      \s*                                 # Ignore trailing whitespace
    />
  }mx

  ATTRIBUTE = /
    ([^=]+)                               # Attribute name
    =                                     # Literal equals sign
    "([^"]*)"                             # Attribute value
  /mx

  def initialize(string)
    @string = string.dup
    @self_closed_tag_template = %{<%%= render "%{component_name}", locals: { %{merged_attrs} } %%>}
    @tag_template = %{<%%= render "%{component_name}", locals: { "content" => "%{content}", %{merged_attrs} } %%>\n}
  end

  def scan
    @string.gsub!(SELF_CLOSING_TAG) do |match|
      component_name = $~[:name]
      attributes = $~[:attributes]
      attrs = extract_attributes(attributes)

      format(@self_closed_tag_template, {
        component_name: component_name,
        merged_attrs: merge_attributes(attrs)
      })
    end

    @string.gsub!(TAG) do |match|
      component_name = $~[:name]
      attributes = $~[:attributes]
      content = $~[:content].to_s

      attrs = extract_attributes(attributes)

      format(@tag_template, {
        component_name: component_name,
        merged_attrs: merge_attributes(attrs),
        content: content.strip.gsub(/\n/, '\n')
      }) + "\n"
    end
 
    @string
  end

  def extract_attributes(string)
    string.scan(ATTRIBUTE).each_with_object({}) do |(key, value), attrs|
      attrs[key.strip] = value.strip
    end
  end

  def merge_attributes(hash)
    hash.map { |k, v| "#{k.inspect} => #{v.inspect}" }.join(" ")
  end
end
