# encoding: utf-8

require 'digest'    # for hash checksum digest function SHA256
require 'pp'        # for pp => pretty printer

## require 'date'
## require 'time'
## require 'json'
## require 'uri'

## our own code
require 'merkletree/version' # note: let version always go first

class MerkleTree
  class Node
    attr_reader :value
    attr_reader :left
    attr_reader :right
    attr_accessor :parent

    def initialize(value, left, right, parent = nil)
      @value = value
      @left  = left
      @right = right
      @parent = parent
    end

    ####
    ## for debugging / testing add pretty printing (dump tree)
    def dump
      do_dump(0)
    end

    def do_dump(depth) ## dump (recursive_worker)
      depth.times { print ' ' }
      print "#{depth}:[#{value}] "
      if @left
        print '{'
        puts
        @left.do_dump(depth + 1)
        @right.do_dump(depth + 1) if @right # note: make right node optional (might be nil/empty)
        depth.times { print ' ' }
        print '}'
      end
      puts
    end # do_dump

    def sibling_value
      if parent
        parent.left == self ? ['r', parent.right.value] : ['l', parent.left.value]
      end
    end

    def recurse_to_root
      ([sibling_value] + (parent.recurse_to_root || [])).compact if parent
    end
  end # class Node

  ## convenience helpers
  def self.for(*args)
    transactions = if args.size == 1 && args[0].is_a?(Array)
                     args[0] ## "unwrap" array in array
                   else
                     args ## use "auto-wrapped" splat array
                   end
    ## for now use to_s for calculation hash
    hashes = transactions.map { |tx| calc_hash(tx.to_s) }
    new(hashes)
  end

  def self.compute_root_for(*args)
    transactions = if args.size == 1 && args[0].is_a?(Array)
                     args[0] ## "unwrap" array in array
                   else
                     args ## use "auto-wrapped" splat array
                   end

    ## for now use to_s for calculation hash
    hashes = transactions.map { |tx| calc_hash(tx.to_s) }
    compute_root(hashes)
  end

  attr_reader :root
  attr_reader :leaves

  def initialize(*args)
    hashes = if args.size == 1 && args[0].is_a?(Array)
               args[0] ## "unwrap" array in array
             else
               args ## use "auto-wrapped" splat array
             end

    @hashes = hashes
    @root   = build_tree
  end

  def build_tree
    level = @leaves = @hashes.map { |hash| Node.new(hash, nil, nil) }

    ## todo/fix: handle hashes.size == 0 case
    ##   - throw exception - why? why not?
    ##   -  return empty node with hash '0' - why? why not?

    if @hashes.size == 1
      level[0]
    else
      ## while there's more than one hash in the layer, keep looping...
      while level.size > 1
        ## loop through hashes two at a time
        level = level.each_slice(2).map do |left, right|
          ## note: handle special case
          # if number of nodes is odd e.g. 3,5,7,etc.
          #   last right node is nil  --  duplicate node value for hash
          ##   todo/check - duplicate just hash? or add right node ref too - why? why not?
          right = left if right.nil?

          new_node = Node.new(MerkleTree.calc_hash(left.value + right.value), left, right)
          left.parent = right.parent = new_node
          new_node
        end
        ## debug output
        ## puts "current merkle hash level (#{level.size} nodes):"
        ## pp level
      end
      ### finally we end up with a single hash
      level[0]
    end
  end # method build tree  ### shortcut/convenience -  compute root hash w/o building tree nodes

  def self.compute_root(*args)
    hashes = if args.size == 1 && args[0].is_a?(Array)
               args[0] ## "unwrap" array in array
             else
               args ## use "auto-wrapped" splat array
             end

    ## todo/fix: handle hashes.size == 0 case
    ##   - throw exception - why? why not?
    ##   -  return empty node with hash '0' - why? why not?

    if hashes.size == 1
      hashes[0]
    else
      ## while there's more than one hash in the list, keep looping...
      while hashes.size > 1
        # if number of hashes is odd e.g. 3,5,7,etc., duplicate last hash in list
        hashes << hashes[-1]   if hashes.size.odd?

        ## loop through hashes two at a time
        hashes = hashes.each_slice(2).map do |left, right|
          ## join both hashes slice[0]+slice[1] together
          hash = calc_hash(left + right)
        end
      end

      ## debug output
      ## puts "current merkle hashes (#{hashes.size}):"
      ## pp hashes
      ### finally we end up with a single hash
      hashes[0]
    end
  end # method compute_root

  def self.calc_hash(data)
    sha = Digest::SHA256.new
    sha.update(data)
    sha.hexdigest
  end

  def self.is_in_tree?(leaf_val, path_to_root, root_value)
    rt = path_to_root.reduce(leaf_val) do |hash, sibling_value|
      sibling_value[0] == 'r' ? calc_hash(hash + sibling_value[1]) : calc_hash(sibling_value[1] + hash)
    end
    rt == root_value
  end
end # class MerkleTree

# say hello
puts MerkleTree.banner if defined?($RUBYLIBS_DEBUG) && $RUBYLIBS_DEBUG
