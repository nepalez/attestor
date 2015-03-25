# encoding: utf-8

describe Attestor::Policy::Node do

  let(:policy_class)  { Attestor::Policy }
  let(:invalid_error) { Attestor::InvalidError }

  describe ".new" do

    it "creates a policy" do
      expect(subject).to be_kind_of policy_class
    end

    it "creates immutable object" do
      expect(subject).to be_frozen
    end

  end # describe .new

  describe "#branches" do

    let(:branches) { 3.times.map { double } }

    it "are initialized from list" do
      subject = described_class.new(*branches)
      expect(subject.branches).to match_array branches
    end

    it "are initialized from array" do
      subject = described_class.new(branches)
      expect(subject.branches).to match_array branches
    end

  end # describe #branches

  describe "#validate" do

    it "raises InvalidError" do
      expect { subject.validate }.to raise_error invalid_error
    end

  end # describe #validate

end # describe Attestor::Policy::Node
