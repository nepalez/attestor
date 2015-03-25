# encoding: utf-8

# describe #valid_policy and #invalid_policy builders
# also describes shared examples for all policies
require "support/policies"

describe Attestor::Policy::Xor do

  subject { described_class.new items }

  describe ".new" do

    let(:items) { [valid_policy] }

    it_behaves_like "creating a node"
    it_behaves_like "creating an immutable object"

  end # context

  describe "#validate" do

    context "when both valid and invalid parts exist" do

      let(:items) { [valid_policy, valid_policy, invalid_policy] }

      it_behaves_like "passing validation"

    end # context

    context "when all parts are valid" do

      let(:items) { 3.times.map { valid_policy } }

      it_behaves_like "failing validation"

    end # context

    context "when all parts are invalid" do

      let(:items) { 3.times.map { invalid_policy } }

      it_behaves_like "failing validation"

    end # context

  end # describe #validate

end # describe Policy::Base::Not
