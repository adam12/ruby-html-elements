# frozen-string-literal: true

require "strscan"

# Scanner which parses HTML using the StringScanner class
class Scanner
  OPENING_TAG = /
    <
      (\w+:\w+) # Tag name
      ([^>]*?)  # Attributes
      (\/?)     # Optional self-closing flag
    >
  /mx

  ATTRIBUTE = /
    ([^=]+)     # Attribute name
    =           # Literal equals sign
    "([^"]*)"   # Attribute value
  /mx

  def initialize(string)
    @scanner = StringScanner.new(string)
    @self_closed_tag_template = "<%%= render \"%{component_name}\", locals: { %{merged_attrs} } %%>"
    @tag_template = "<%%= render \"%{component_name}\", locals: { \"content\" => \"%{content}\", %{merged_attrs} } %%>\n"
  end

  def scan
    output = +""

    until @scanner.eos?
      if @scanner.scan(OPENING_TAG) 
        component_name = @scanner[1]
        attributes = @scanner[2].strip
        self_close = @scanner[3] == "/"

        attrs = attributes.scan(ATTRIBUTE).each_with_object({}) do |(key, value), attrs|
          attrs[key] = value
        end

        merged_attrs = attrs.map { |k, v| "#{k.inspect} => #{v.inspect}" }.join(" ")

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
end
