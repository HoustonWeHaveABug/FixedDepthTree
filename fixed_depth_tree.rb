class String
	def is_integer?
		self.to_i.to_s == self
	end
end

class FixedDepthTree
	class Level
		attr_reader :start_min, :groups_min, :start_max, :groups_max

		def initialize(start_min, groups_min, branching_min, parent_nodes)
			@start_min = start_min
			@groups_min = groups_min
			@start_max = start_min+groups_min*branching_min
			@groups_max = parent_nodes-groups_min
		end

		def output
			puts "StartMin #{@start_min} GroupsMin #{@groups_min} StartMax #{@start_max} GroupsMax #{@groups_max}"
		end
	end

	private_constant :Level

	def initialize(depth, nodes_n)
		if depth < 1 || depth > nodes_n || (depth == 1 && nodes_n > 1)
			@levels_n = 0
			@nodes_n = 0
			@branching_min = 0
			@branching_max = 1
			@levels = Array.new
			return
		end
		@levels_n = depth-1
		@nodes_n = nodes_n
		branching_lo = 0
		branching_hi = nodes_n-1
		while branching_lo <= branching_hi
			@branching_min = (branching_lo+branching_hi)/2
			if count_nodes(@branching_min) < nodes_n
				@branching_max = @branching_min+1
				nodes_max = count_nodes(@branching_max)
				if nodes_max < nodes_n
					branching_lo = @branching_min+1
				else
					break
				end
			else
				branching_hi = @branching_min-1
			end
		end
		@levels = Array.new
		parent_nodes = 1
		queued_nodes = nodes_n-1
		nodes_max = (nodes_max-1)/@branching_max
		@levels_n.times do
			child_nodes = queued_nodes/nodes_max
			if queued_nodes%nodes_max > 0
				child_nodes += 1
			end
			child_nodes_min = parent_nodes*@branching_min
			if child_nodes < child_nodes_min
				child_nodes = child_nodes_min
			end
			@levels.push(Level.new(nodes_n-queued_nodes, parent_nodes*@branching_max-child_nodes, @branching_min, parent_nodes))
			parent_nodes = child_nodes
			queued_nodes -= parent_nodes
			nodes_max = (nodes_max-1)/@branching_max
		end
	end

	def get_parent_group(level, node)
		if node < level.start_max
			return (node-level.start_min)/@branching_min
		end
		level.groups_min+(node-level.start_max)/@branching_max
	end

	def get_parent_link(node)
		link = Array.new
		if node < 0 || node >= @nodes_n
			return link
		end
		group = 0
		@levels.reverse.each do |level|
			if node >= level.start_min
				if node < level.start_max+level.groups_max*@branching_max
					link.push(node)
					group = get_parent_group(level, node)
				else
					return link.push(level.start_min+group)
				end
			end
		end
		link.push(group)
	end

	def get_path_from(node)
		path = Array.new
		if node < 0 || node >= @nodes_n
			return path
		end
		group = 0
		@levels.reverse.each do |level|
			if node >= level.start_min
				if node < level.start_max+level.groups_max*@branching_max
					parent = node
				else
					parent = level.start_min+group
				end
				path.push(parent)
				group = get_parent_group(level, parent)
			end
		end
		path.push(group)
	end

	def get_children_links(node)
		links = Array.new
		if node < 0 || node >= @nodes_n
			return links
		end
		if node == 0
			links.push(node)
			group = node
		end
		@levels.each do |level|
			if node >= level.start_min
				if node < level.start_max+level.groups_max*@branching_max
					links.push(node)
					group = node-level.start_min
				end
			else
				if group < level.groups_min
					return links.push(@branching_min).push(level.start_min+group*@branching_min)
				end
				return links.push(@branching_max).push(level.start_max+(group-level.groups_min)*@branching_max)
			end
		end
		links.push(0)
	end

	def output
		puts "LevelsN #{@levels_n} NodesN #{@nodes_n} BranchingMin #{@branching_min} BranchingMax #{@branching_max}"
		@levels.each do |level|
			level.output
		end
	end

	private

	def count_nodes(branching)
		nodes_n = 1
		children = branching
		@levels_n.times do
			nodes_n += children
			children *= branching
		end
		nodes_n
	end
end

argc = ARGV.size
if argc < 2 || !ARGV[0].is_integer? || !ARGV[1].is_integer?
	STDERR.puts "Invalid arguments"
	STDERR.flush
	exit false
end
tree = FixedDepthTree.new(ARGV[0].to_i, ARGV[1].to_i)
tree.output
STDOUT.flush
ARGV[2..argc-1].each do |node_str|
	if !node_str.is_integer?
		STDERR.puts "Invalid argument"
		STDERR.flush
		exit false
	end
	node = node_str.to_i
	puts "GetParentLink #{tree.get_parent_link(node)}"
	puts "GetPathFrom #{tree.get_path_from(node)}"
	puts "GetChildrenLinks #{tree.get_children_links(node)}"
	STDOUT.flush
end
