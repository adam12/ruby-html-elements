require "minitest/autorun"
require_relative "re_scanner"

STRING = <<~'EOM'
1 This is outside of the component
2
<some:component some-attribute="some-value">
This is the content

Multi-line
</some:component>
6
7 Bar
8 <somecomponent>
9 This is the other content
10 </somecomponent>
11
<some:selfclosing />
EOM

EXPECTED = <<~'EOM'
1 This is outside of the component
2
<%= render "some:component", locals: { "content" => "This is the content\n\nMulti-line", "some-attribute" => "some-value" } %>


6
7 Bar
8 <somecomponent>
9 This is the other content
10 </somecomponent>
11
<%= render "some:selfclosing", locals: {  } %>
EOM

class TestScanner < Minitest::Test
  make_my_diffs_pretty!

  def test_scans
    scanner = ReScanner.new(STRING)

    result = scanner.scan

    assert_equal EXPECTED, result
  end
end

