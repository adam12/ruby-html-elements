require "bundler/setup"
require "benchmark/ips"
require_relative "scanner"
require_relative "re_scanner"
require_relative "backref_scanner"

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

  x.report("BackrefScanner") { BackrefScanner.new(STRING).scan }

  x.compare!
end

__END__

$ ruby --yjit benchmark.rb
ruby 3.3.4 (2024-07-09 revision be1089c8ec) +YJIT [arm64-darwin23]
Warming up --------------------------------------
             Scanner     1.578k i/100ms
           ReScanner     4.258k i/100ms
      BackrefScanner     4.600k i/100ms
Calculating -------------------------------------
             Scanner     14.622k (±12.3%) i/s -     72.588k in   5.074484s
           ReScanner     65.387k (±13.9%) i/s -    315.092k in   5.002886s
      BackrefScanner     66.842k (± 5.1%) i/s -    335.800k in   5.043488s

Comparison:
      BackrefScanner:    66841.8 i/s
           ReScanner:    65386.8 i/s - same-ish: difference falls within error
             Scanner:    14621.7 i/s - 4.57x  slower
