# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_build.rb


require 'helper'


class TestBuild < MiniTest::Test

def test_version
   pp MerkleTree.version
   pp MerkleTree.banner
   pp MerkleTree.root

   assert true  ## (for now) everything ok if we get here
end

def test_example_even

hashes = [
  "00",
  "11",
  "22",
  "33",
]

merkle = MerkleTree.new( hashes )

puts "merkletree root hash:"
puts merkle.root.value

puts "merkletree:"
pp merkle.root


  assert true  ## (for now) everything ok if we get here


######
#  will print something like:
#
# current merkle hash list (2):
#   ["4ff2b6e318d979927a8c780b5e16cf36dc11ee9f95c5f132279d52f21a051520",
#    "4d479b4b92c57b9bfcd55f7b674f66f098af8c8de1036b4c419b427c6cd31c83"]
# current merkle hash list (1):
#   ["5bffe87c7fd53d98f166661dd6a2d368ba0acc0b5c773d8426f4f153ff23125c"]
# merkletree hash:
#     5bffe87c7fd53d98f166661dd6a2d368ba0acc0b5c773d8426f4f153ff23125c

end

end  # class TestBlock
