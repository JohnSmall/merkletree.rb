# encoding: utf-8

require 'digest'    # for hash checksum digest function SHA256
require 'pp'        # for pp => pretty printer

require 'date'
require 'time'
require 'json'
require 'uri'



## our own code
require 'merkletree/version'    # note: let version always go first





class MerkleTree

  class Node
    attr_reader :value
    attr_reader :left
    attr_reader :right

    def initialize( value, left, right )
       @value = value
       @left  = left
       @right = right
    end
  end # class Node





  attr_reader :root
  attr_reader :leaves

  def initialize( hashes=[] )
    @hashes = hashes
    @root   = build_tree
  end


  def build_tree
    layer = @leaves = @hashes.map { |hash| Node.new( hash, nil, nil ) }

    if @hashes.size == 1
      layer[0]
    else
      ## while there's more than one hash in the layer, keep looping...
      while layer.size > 1
        ## fix/todo:  check for odd (not even) - auto-add clone
        ## loop through hashes two at a time
        layer = layer.each_slice(2).map do |left, right|
          Node.new( calc_hash( left.value + right.value ), left, right)
        end
        ## debug output
        puts "current merkle hash layer (#{layer.size}):"
        pp layer
      end
      ### finally we end up with a single hash
      layer[0]
    end
  end  # method build tree


private

  def old_compute_merkletree_hash( hashes )

  if hashes.empty?
    return "0"   ## return null hash (fix: what's the (proper) null hash?)
  elsif hashes.size == 1
    return hashes[0]
  else
    ## while there's more than one hash in the list, keep looping...
    while hashes.size > 1
      # if number of hashes is odd e.g. 3,5,7,etc., duplicate last hash in list
      hashes << hashes[-1]   if hashes.size % 2 != 0

      ## new hash list
      new_hashes = []
      ## loop through hashes two at a time
      hashes.each_slice(2) do |slice|
        ## join both hashes slice[0]+slice[1] together
        hash = calc_hash( slice[0]+slice[1] )
        new_hashes << hash
      end
      hashes = new_hashes

      ## debug output
      puts "current merkle hash list (#{hashes.size}):"
      pp hashes
    end
    ### finally we end up with a single hash
    hashes[0]
   end
end # method compute_merkletree_hash

  def calc_hash( data )
    sha = Digest::SHA256.new
    sha.update( data )
    sha.hexdigest
  end


end # class MerkleTree


# say hello
puts MerkleTree.banner    if defined?($RUBYLIBS_DEBUG) && $RUBYLIBS_DEBUG
