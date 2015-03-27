# encoding: utf-8

describe Attestor::Policy do

  let(:factory)   { Attestor::Policy::Factory }
  let(:validator) { Attestor::Validations }
  let(:invalid)   { Attestor::InvalidError.new subject, [] }
  let(:others)    { 2.times { double } }

  let(:test_class) { Class.new.send(:include, described_class) }
  before  { Test = test_class }
  after   { Object.send :remove_const, :Test }
  subject { test_class.new }

  it "is a factory" do
    expect(test_class).to be_kind_of factory
  end

  describe ".new" do

    let(:build) { described_class.new(:foo) { attr_reader :bar } }
    subject     { build.new(:baz) }

    it "builds the struct" do
      expect(subject).to be_kind_of Struct
    end

    it "adds given attributes" do
      expect(subject.foo).to eq :baz
    end

    it "builds the policy" do
      expect(subject).to be_kind_of described_class
    end

    it "yields the block in class scope" do
      expect(subject).to respond_to :bar
    end

  end

  describe ".included" do

    it "creates a validator" do
      expect(subject).to be_kind_of validator
    end

  end # describe .new

  describe "#valid?" do

    context "when #validate method fails" do

      before { allow(subject).to receive(:validate) { fail invalid } }

      it "returns false" do
        expect(subject.valid?).to eq false
      end

    end

    context "when #validate method passes" do

      before { allow(subject).to receive(:validate) { nil } }

      it "returns true" do
        expect(subject.valid?).to eq true
      end

    end

  end # describe #valid?

  describe "#invalid?" do

    context "when #validate method fails" do

      before { allow(subject).to receive(:validate) { fail invalid } }

      it "returns true" do
        expect(subject.invalid?).to eq true
      end

    end

    context "when #validate method passes" do

      before { allow(subject).to receive(:validate) { nil } }

      it "returns false" do
        expect(subject.invalid?).to eq false
      end

    end

  end # describe #invalid?

  describe "#and" do

    it "calls .and class factory method with self" do
      expect(test_class).to receive(:and).with(subject, *others)
      subject.and(*others)
    end

  end # describe #and

  describe "#or" do

    it "calls .or class factory method with self" do
      expect(test_class).to receive(:or).with(subject, *others)
      subject.or(*others)
    end

  end # describe #or

  describe "#xor" do

    it "calls .xor class factory method with self" do
      expect(test_class).to receive(:xor).with(subject, *others)
      subject.xor(*others)
    end

  end # describe #xor

  describe "#not" do

    it "calls .not class factory method with self" do
      expect(test_class).to receive(:not).with(subject)
      subject.not
    end

  end # describe #not

end # describe Attestor::Policy
