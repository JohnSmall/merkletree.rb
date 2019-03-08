# encoding: utf-8

###
#  to run use
#     ruby -I ./lib -I ./test test/test_build.rb

require 'helper'

class TestBuild < MiniTest::Test
  def test_example_4
    hashes = %w[
      00
      11
      22
      33
    ]

    hash00   = '00'
    hash11   = '11'
    hash0011 = MerkleTree.calc_hash(hash00 + hash11)

    hash22   = '22'
    hash33   = '33'
    hash2233 = MerkleTree.calc_hash(hash22 + hash33)

    hash00112233 = MerkleTree.calc_hash(hash0011 + hash2233)

    merkle = MerkleTree.new(hashes)

    # puts 'merkletree root hash:'
    # puts merkle.root.value
    #
    # puts 'merkletree:'
    # pp merkle.root

    assert_equal hash00, merkle.root.left.left.value
    assert_equal hash11, merkle.root.left.right.value
    assert_equal hash22, merkle.root.right.left.value
    assert_equal hash33, merkle.root.right.right.value

    assert_equal hash0011, merkle.root.left.value
    assert_equal hash2233, merkle.root.right.value

    assert_equal hash00112233, merkle.root.value

    merkle_root_value = MerkleTree.compute_root(hashes)
    # puts 'merkletree root hash:'
    # puts merkle_root_value

    assert_equal merkle.root.value, merkle_root_value
  end # method test_example_4

  def test_example_3 ## test odd (not even hashes)
    hashes = %w[
      00
      11
      22
    ]

    hash00   = '00'
    hash11   = '11'
    hash0011 = MerkleTree.calc_hash(hash00 + hash11)

    hash22   = '22'
    hash2222 = MerkleTree.calc_hash(hash22 + hash22)

    hash00112222 = MerkleTree.calc_hash(hash0011 + hash2222)

    merkle = MerkleTree.new(hashes)

    # puts 'merkletree root hash:'
    # puts merkle.root.value

    # ## try handcoded pretty printer (dump)
    # merkle.root.dump
    #
    # puts 'merkletree:'
    # pp merkle.root

    assert_equal hash00, merkle.root.left.left.value
    assert_equal hash11, merkle.root.left.right.value
    assert_equal hash22, merkle.root.right.left.value
    assert_equal hash22, merkle.root.right.right.value

    assert_equal hash0011, merkle.root.left.value
    assert_equal hash2222, merkle.root.right.value

    assert_equal hash00112222, merkle.root.value

    merkle_root_value = MerkleTree.compute_root(hashes)
    # puts 'merkletree root hash:'
    # puts merkle_root_value

    assert_equal merkle.root.value, merkle_root_value
  end # method test_example_3

  def test_example_5 ## test odd (not even hashes)
    hashes = %w[
      0000
      0011
      0022
      0033
      0044
    ]

    merkle = MerkleTree.new(hashes)

    # puts 'merkletree root hash:'
    # puts merkle.root.value

    # puts 'merkletree:'
    # pp merkle.root

    ## try handcoded pretty printer (dump)
    # merkle.root.dump

    merkle_root_value = MerkleTree.compute_root(hashes)
    # puts 'merkletree root hash:'
    # puts merkle_root_value

    assert_equal merkle.root.value, merkle_root_value
  end # method test_example_5

  def test_tulips
    merkle = MerkleTree.for(
      { from: 'Dutchgrown', to: 'Vincent', what: 'Tulip Bloemendaal Sunset', qty: 10 },
      from: 'Keukenhof', to: 'Anne', what: 'Tulip Semper Augustus', qty: 7
    )

    # puts 'merkletree root hash:'
    # puts merkle.root.value

    # puts 'merkletree:'
    # pp merkle.root

    merkle_root_value = MerkleTree.compute_root_for(
      { from: 'Dutchgrown', to: 'Vincent', what: 'Tulip Bloemendaal Sunset', qty: 10 },
      from: 'Keukenhof', to: 'Anne', what: 'Tulip Semper Augustus', qty: 7
    )

    # puts 'merkletree root hash:'
    # puts merkle_root_value

    assert_equal merkle.root.value, merkle_root_value
  end # method test_tulips

  def test_node_parent
    hashes = %w[
      0000
      0011
      0022
      0033
      0044
      0055
    ]

    merkle = MerkleTree.new(hashes)
    leaf = merkle.leaves[2]
    assert_equal leaf.parent.left, leaf
    leaf = merkle.leaves[1]
    assert_equal leaf.parent.right, leaf
  end

  def test_leaf_node_sibling
    hashes = %w[
      0000
      0011
      0022
      0033
      0044
      0055
    ]
    merkle = MerkleTree.new(hashes)
    leaf1 = merkle.leaves[2]
    leaf2 = merkle.leaves[3]
    assert_equal leaf1.sibling_value, ['r', leaf2.value]
    assert_equal leaf2.sibling_value, ['l', leaf1.value]
    assert_nil merkle.root.sibling_value
  end

  def test_root_node_sibling_is_nil
    hashes = %w[
      0000
      0011
      0022
      0033
      0044
      0055
    ]
    merkle = MerkleTree.new(hashes)
    assert_nil merkle.root.sibling_value
  end

  def test_path_to_root
    hashes = %w[
      0000
      0011
      0022
      0033
      0044
      0055
    ]
    merkle = MerkleTree.new(hashes)
    leaf = merkle.leaves[2]
    path_to_root = leaf.recurse_to_root
    rt = path_to_root.reduce(leaf.value) do |hash, sibling_value|
      sibling_value[0] == 'r' ? MerkleTree.calc_hash(hash + sibling_value[1]) : MerkleTree.calc_hash(sibling_value[1] + hash)
    end
    assert_equal rt, merkle.root.value
  end

  def test_is_in_tree
    hashes = %w[
      0000
      0011
      0022
      0033
      0044
      0055
    ]
    merkle = MerkleTree.new(hashes)
    leaf = merkle.leaves[2]
    path_to_root = leaf.recurse_to_root
    assert MerkleTree.is_in_tree?('0022', path_to_root, merkle.root.value)
    assert !MerkleTree.is_in_tree?('0066', path_to_root, merkle.root.value)
  end
end
# class TestBuild
