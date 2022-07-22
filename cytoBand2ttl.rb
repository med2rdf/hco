#!/usr/bin/env ruby
#
# $ curl http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/cytoBand.txt.gz | gzip -dc - > cytoBand-GRCh37.txt
# $ curl http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/cytoBand.txt.gz | gzip -dc - > cytoBand-GRCh38.txt
# $ ruby cytoBand2ttl.rb > cytoBand.ttl
#

hash = {}

cytoband_type = {
  "acen" => "hco:Acen",
  "gneg" => "hco:Gneg",
  "gpos100" => "hco:Gpos100",
  "gpos25" => "hco:Gpos25",
  "gpos50" => "hco:Gpos50",
  "gpos75" => "hco:Gpos75",
  "gvar" => "hco:Gvar",
  "stalk" => "hco:Stalk",
}

versions = [ "GRCh37", "GRCh38" ]

versions.each do |ver|
  File.open("cytoBand-#{ver}.txt") do |file|
    file.each do |line|
      chr, from, to, band, col = line.strip.split
      if pat = /^chr(\d{1,2}|[XY])$/.match(chr)
        num = pat[1]
        cyto = "#{num}#{band}"
        hash[cyto] ||= {}
        hash[cyto][ver] = {
          :from => from.to_i + 1,
          :to   => to.to_i,
          :cyto => cyto,
          :col  => col,
          :ref  => "hco:#{num}\\/#{ver}"
        }
      end
    end
  end
end

hash.each do |cyto, data|
  puts "hco:#{cyto}"
  puts "\trdf:type\towl:Class ;"
  puts "\trdfs:label\t\"#{cyto}\" ;"
  puts "\trdfs:subClassOf\thco:Cytoband ."
  puts
  versions.each do |ver|
    h = data[ver]
    puts "hco:#{cyto}\\/#{ver}"
    puts "\trdf:type\thco:#{cyto} ;"
    puts "\thco:build\thco:#{ver} ;"
    puts "\thco:bandtype\t#{cytoband_type[h[:col]]} ;"
    puts "\tfaldo:location\t["
    puts "\t\trdf:type\tfaldo:Region ;"
    puts "\t\tfaldo:begin\t["
    puts "\t\t\trdf:type\tfaldo:BothStrandsPosition ;"
    puts "\t\t\tfaldo:position\t#{h[:from]} ;"
    puts "\t\t\tfaldo:reference\t#{h[:ref]}"
    puts "\t\t] ;"
    puts "\t\tfaldo:end\t["
    puts "\t\t\trdf:type\tfaldo:BothStrandsPosition ;"
    puts "\t\t\tfaldo:position\t#{h[:to]} ;"
    puts "\t\t\tfaldo:reference\t#{h[:ref]}"
    puts "\t\t]"
    puts "\t] ."
    puts
  end
end
