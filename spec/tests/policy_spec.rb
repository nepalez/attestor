# encoding: utf-8

describe Attestor::Policy do

  let(:validator) { Attestor::Validations }
  let(:invalid)   { Attestor::InvalidError.new subject, [] }

  let(:test_class) { Class.new.send(:include, described_class) }
  before  { Test = test_class }
  after   { Object.send :remove_const, :Test }
  subject { test_class.new }

  describe ".new" do

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

end # describe Attestor::Policy
