# frozen-string-literal: true

# Scanner which parses HTML using gsub! but with backreferences
class BackrefScanner
  TAG = Regexp.compile(<<~'__REGEXP__'.strip, Regexp::EXTENDED)
    (?<element> \g<stag> \g<content>* \g<etag> ){0}
    (?<stag> < \g<name> \s* \g<attributes> >){0}
    (?<name> [\w_]+:[\w_]+ ){0}
    (?<attributes> [^>]*? ){0}
    (?<content> [^<&]+ (\g<element> | [^<&]+)* ){0}
    (?<etag> </ \k<name+1> >){0}
    \g<element>
  __REGEXP__

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
