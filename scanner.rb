# frozen-string-literal: true

require "strscan"

# Scanner which parses HTML using the StringScanner class
class Scanner
  OPENING_TAG = /
    <
      (?<name> \w+:\w+)       # Tag name
      (?<attributes> [^>]*?)  # Attributes
      (?<self_close> \/?)     # Optional self-closing flag
    >
  /mx

  ATTRIBUTE = /
    ([^=]+)                   # Attribute name
    =                         # Literal equals sign
    "([^"]*)"                 # Attribute value
  /mx

  def initialize(string)
    @scanner = StringScanner.new(string)
    @self_closed_tag_template = %{<%%= render "%{component_name}", locals: { %{merged_attrs} } %%>}
    @tag_template = %{<%%= render "%{component_name}", locals: { "content" => "%{content}", %{merged_attrs} } %%>\n}
  end

  def scan
    output = +""

    until @scanner.eos?
      if @scanner.scan(OPENING_TAG) 
        component_name = @scanner[:name]
        attributes = @scanner[:attributes].strip
        self_close = @scanner[:self_close] == "/"

        attrs = extract_attributes(attributes)
        merged_attrs = merge_attributes(attrs)

        if self_close
          output << format(@self_closed_tag_template, {
            component_name: component_name,
            merged_attrs: merged_attrs
          })
        else
          content = +""
          loop do
            break if @scanner.scan(%r{</#{component_name}>})

            content << @scanner.getch
          end

          line = format(@tag_template, {
            component_name: component_name,
            merged_attrs: merged_attrs,
            content: content.strip.gsub(/\n/, '\n')
          })

          output << line
          output << "\n" # New line that existed on closing tag
        end
      else
        output << @scanner.getch
      end
    end

    output
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
