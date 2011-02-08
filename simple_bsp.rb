#!/usr/bin/env ruby
#require 'json'

class StdoutObserver
  def observe_nodes nodes, iter
    puts ">#{iter}"
    nodes.each { |node| puts [ node.id, node.connected_component_id, node.stable ].join("|") }
  end
end

class DotObserver

  def observe_nodes nodes, iter

    # build hue range first time only to keep colours consistent
    if @connected_component_id_to_hue.nil?
      @connected_component_id_to_hue = {}
      connected_component_ids = nodes.collect(&:connected_component_id).uniq.shuffle
      connected_component_ids.each_with_index do |cc,idx| 
        @connected_component_id_to_hue[cc] = idx.to_f / connected_component_ids.size
      end
    end

    dot_filename = "dot.#{rand()}.dot"
    dot_file = File.new(dot_filename,'w')

    dot_file.puts "graph {"
    dot_file.puts "node [ style=filled ];"

    # node attributes
    nodes.each do |node|
      hue = @connected_component_id_to_hue[node.connected_component_id]
      dot_file.puts "\"#{node.id}\" [color=\"#{hue}+1.0+1.0\"]"
    end
    
    # edge attributes
    nodes.each do |node|
      node.neighbours.each do |neighbour|
        next unless node.id < neighbour.id
        dot_file.puts "#{node.id} -- #{neighbour.id}"
      end
    end

    dot_file.puts "}"
    dot_file.close

    # fdp => 1m15s, neato => 45s
    png_file = sprintf("graph.%03d.png", iter)
    cmd = "fdp -Tpng < #{dot_filename} > #{png_file}; rm #{dot_filename}"
    puts cmd
    `#{cmd}`
  end

end

class Node

  attr_accessor :neighbours, :id, :connected_component_id, :stable, :messages

  def initialize id
    @neighbours = []
    @id = id
    @connected_component_id = id 
    @stable = false
    @messages = [] 
  end

  def broadcast
    return if @stable
    @neighbours.each do |neighbour|
      neighbour.messages << @connected_component_id
    end
    @messages << @connected_component_id
  end

  def process_messages
    if @messages.empty?
      @stable = true
      return
    end
    min_id_from_neighbours_and_self = @messages.inject{|a,v| a < v ? a : v}
    if min_id_from_neighbours_and_self < @connected_component_id
      @connected_component_id = min_id_from_neighbours_and_self
      @stable = false
    else
      @stable = true
    end
    @messages.clear
  end
  
  def to_s
    # { :iter => iter, :id => @id, :cc_id => @cc_id, :stable => stable }.to_json
    [ iter, @id, @connected_component_id, @stable ].join("|")
  end

end

# read in graph
graph = {}
STDIN.each do |edge|
  from, to = edge.split("\t").map(&:to_i)
  graph[from] ||= Node.new from
  graph[from].neighbours << to
  graph[to] ||= Node.new to
  graph[to].neighbours << from
end

# hook up neighbours as nodes, instead of ids
nodes = graph.values.sort { |a,b| a.id <=> b.id }
nodes.each do |node|
  neighbours_as_nodes = node.neighbours.map{ |id| graph[id] }
  node.neighbours = neighbours_as_nodes
end

#observer = StdoutObserver.new
observer = DotObserver.new

iter = 0
converged = false
while !converged do
  observer.observe_nodes nodes, iter

  nodes.each { |node| node.broadcast }
  nodes.each { |node| node.process_messages }

  converged = nodes.inject { |all_converged, node| all_converged && node.stable } 

  iter += 1
end

observer.observe_nodes nodes, iter

connected_components = nodes.collect(&:connected_component_id).uniq.sort
STDERR.puts "# connected_components = #{connected_components.size}"
STDERR.puts "connected_components = #{connected_components.inspect}"

  



