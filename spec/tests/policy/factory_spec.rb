# encoding: utf-8

describe Attestor::Policy::Factory do

  let(:test_class) { Class.new.send :include, described_class }
  let(:subject)    { test_class.new }
  let(:policy)     { double :policy }
  let(:others)     { 2.times.map { double } }

  shared_examples "creating a node" do |composer|

    it "[creates a Node]" do
      expect(result).to be_kind_of composer
    end

    it "[sets policies]" do
      expect(result.branches).to match_array [policy, *others]
    end

  end # shared examples

  shared_examples "creating a negator" do |composer|

    it "[creates a Negator]" do
      expect(result).to be_kind_of Attestor::Policy::Negator
    end

    it "[sets a policy]" do
      expect(result.policy).to eq policy
    end

    it "[sets a composer]" do
      expect(result.composer).to eq composer
    end

  end # shared examples

  describe "#and" do

    context "with one argument" do

      let(:result) { subject.and(policy, []) }
      it_behaves_like "creating a negator", Attestor::Policy::And

    end # context

    context "with several arguments" do

      let(:result) { subject.and(policy, others) }
      it_behaves_like "creating a node", Attestor::Policy::And

    end # context

  end # describe #and

  describe "#or" do

    context "with one argument" do

      let(:result) { subject.or(policy, []) }
      it_behaves_like "creating a negator", Attestor::Policy::Or

    end # context

    context "with several arguments" do

      let(:result) { subject.or(policy, others) }
      it_behaves_like "creating a node", Attestor::Policy::Or

    end # context

  end # describe #or

  describe "#xor" do

    context "with one argument" do

      let(:result) { subject.xor(policy, []) }
      it_behaves_like "creating a negator", Attestor::Policy::Xor

    end # context

    context "with several arguments" do

      let(:result) { subject.xor(policy, others) }
      it_behaves_like "creating a node", Attestor::Policy::Xor

    end # context

  end # describe #or

  describe "#not" do

    let(:others) { [] }
    let(:result) { subject.not(policy) }
    it_behaves_like "creating a node", Attestor::Policy::Not

  end # describe #or

end # describe Attestor::Policy::Factory
