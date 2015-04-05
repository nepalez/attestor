# encoding: utf-8

describe Attestor::Policy::Node do

  let(:policy_module) { Attestor::Policy       }
  let(:invalid_error) { Attestor::InvalidError }

  describe ".new" do

    it "creates a policy" do
      expect(subject).to be_kind_of policy_module
    end

    it "creates a collection" do
      expect(subject).to be_kind_of Enumerable
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

  describe "#each" do

    let(:branches) { 3.times.map { |n| double validate: n } }

    it "returns an enumerator" do
      expect(subject.each).to be_kind_of Enumerator
    end

    it "iterates through branches' validation reports" do
      subject = described_class.new(branches)
      expect(subject.to_a).to eq [1, 2, 3]
    end

  end # each

  describe "#validate!" do

    let(:message) { Attestor::Validations::Message.new :base, subject }

    it "raises InvalidError" do
      expect { subject.validate! }.to raise_error invalid_error
    end

    it "adds the :invalid message" do
      begin
        subject.validate!
      rescue => error
        expect(error.messages).to contain_exactly message
      end
    end

  end # describe #validate!

end # describe Attestor::Policy::Node
