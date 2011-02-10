#!/usr/bin/env ruby
STDIN.each do |line|
  id,cc_id,neighbours = line.chomp.split "\t"
  puts line
  neighbours.split.each do |neighbour|
    puts "#{neighbour}\t#{cc_id}"
  end
end
