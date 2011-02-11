#!/usr/bin/env ruby
last_id, min_cc_id, last_neighbours = nil

STDIN.each do |line|

  cols = line.chomp.split "\t"
  if cols.length == 3
    id, cc_id, neighbours = cols
  elsif cols.length == 2
    id, cc_id = cols
  else
    STDERR.puts "reporter:counter:custom,invalid_record,1"
  end

  if last_id != nil && last_id != id
    # switching to new id, emit min for last
    puts [last_id, min_cc_id, last_neighbours].join("\t") 
    min_cc_id = nil
  end

  # collecting min_cc_id
  cc_id = cc_id.to_i
  min_cc_id ||= cc_id
  min_cc_id = cc_id if cc_id < min_cc_id

  # retain last id (and neighbours if we collected it this record)
  last_id = id
  last_neighbours = neighbours if neighbours

end

puts [last_id, min_cc_id, last_neighbours].join("\t") 

