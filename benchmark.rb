require "bundler/setup"
require "benchmark/ips"
require_relative "scanner"
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

Benchmark.ips do |x|
  x.report("Scanner") { Scanner.new(STRING).scan }

  x.report("ReScanner") { ReScanner.new(STRING).scan }

  x.compare!
end

__END__

ruby --yjit benchmark.rb
ruby 3.3.4 (2024-07-09 revision be1089c8ec) +YJIT [arm64-darwin23]
Warming up --------------------------------------
             Scanner     1.549k i/100ms
           ReScanner     7.382k i/100ms
Calculating -------------------------------------
             Scanner     15.391k (± 2.0%) i/s -     77.450k in   5.034103s
           ReScanner     69.458k (± 1.2%) i/s -    354.336k in   5.102207s

Comparison:
           ReScanner:    69458.3 i/s
             Scanner:    15391.2 i/s - 4.51x  slower
