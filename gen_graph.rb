#!/usr/bin/env ruby

raise "usage: #{$0} NUM_NODES NUM_EDGES MIN_NUM_CONNECTED_COMPONENTS" unless ARGV.length == 3
NUM_NODES, NUM_EDGES, MIN_NUM_CONNECTED_COMPONENTS = ARGV.map(&:to_i)

class GraphGenerator
  def initialize min, max # min inclusive, max exclusive
    @min = min
    @range = max - min
  end
  def random_node
    rand(@range) + @min
  end
  def random_edge
    node1 = random_node
    node2 = node1
    while node1 == node2
      node2 = random_node
    end
    [node1, node2].sort
  end
end

# splits, include boundaries, with uniq nodes
# and also don't allow any nodes one off from another; a graph of min=4, max=5 wouldn't be able to generate an edge
splits = [0, NUM_NODES-1]
while splits.size < MIN_NUM_CONNECTED_COMPONENTS+2
  rnd_node = rand(NUM_NODES-1)
  if !(splits.include?(rnd_node) || splits.include?(rnd_node-1) || splits.include?(rnd_node+1) )
    splits << rnd_node 
  end
end
splits.sort!
STDERR.puts "splits #{splits.inspect}"

# convert from splits to generators
generators = []
from = splits.shift
while not splits.empty?
  to = splits.shift
  generators << GraphGenerator.new(from, to)
  from = to
end

# generate edges
NUM_EDGES.times do |i|
  g = generators[i%generators.length]
  puts g.random_edge.join("\t")
end
