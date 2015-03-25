# encoding: utf-8

describe Attestor::Policy::Negator do

  let(:composer)  { Attestor::Policy::Node }
  let(:not_class) { Attestor::Policy::Not  }
  let(:policy)    { double :policy }

  subject { described_class.new composer, policy }

  describe ".new" do

    it "creates immutable object" do
      expect(subject).to be_frozen
    end

  end

  describe "#policy" do

    it "is initialized" do
      expect(subject.policy).to eq policy
    end

  end # describe #policy

  describe "#composer" do

    it "is initialized" do
      expect(subject.composer).to eq composer
    end

  end # describe #composer

  describe "#not" do

    let(:another) { double :another }
    let(:result)  { subject.not(another) }

    it "creates a composer object" do
      expect(result).to be_kind_of composer
    end

    it "sends its policy to the composer" do
      expect(result.branches).to include policy
    end

    it "sends the negated arguments to the composer" do
      negation = double :negation
      expect(not_class).to receive(:new).with(another).and_return(negation)

      expect(result.branches).to include negation
    end

  end # describe #not

end # describe Policy::Base::Negator
