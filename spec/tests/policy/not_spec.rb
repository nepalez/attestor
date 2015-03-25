# encoding: utf-8

# describe #valid_policy and #invalid_policy builders
# also describes shared examples for all policies
require "support/policies"

describe Attestor::Policy::Not do

  subject { described_class.new item }

  describe ".new" do

    let(:item) { valid_policy }

    it_behaves_like "creating a node"
    it_behaves_like "creating an immutable object"

  end # context

  describe "#validate" do

    context "when a part is invalid" do

      let(:item) { invalid_policy }

      it_behaves_like "passing validation"

    end # context

    context "when a part is valid" do

      let(:item) { valid_policy }

      it_behaves_like "failing validation"

    end # context

  end # describe #validate

end # describe Policy::Base::Not
