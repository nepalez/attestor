# encoding: utf-8

describe Attestor::Report do

  let(:invalid_error) { Attestor::InvalidError }

  let(:messages) { ["foo"] }
  let(:object)   { double  }
  let(:error)    { invalid_error.new   object, messages }
  subject        { described_class.new object, error    }

  describe ".new" do

    it "creates an immutable object" do
      expect(subject).to be_frozen
    end

  end # describe .new

  describe "#object" do

    it "is initialized" do
      expect(subject.object).to eq object
    end

  end # describe #object

  describe "#error" do

    it "is initialized" do
      expect(subject.error).to eq error
    end

    it "is set to nil by default" do
      expect(described_class.new(object).error).to be_nil
    end

  end # describe #error

  describe "#valid?" do

    context "when the #error is set" do

      it "returns false" do
        expect(subject.valid?).to eq false
      end

    end # context

    context "when the #error is not set" do

      subject { described_class.new object }

      it "returns true" do
        expect(subject.valid?).to eq true
      end

    end # context

  end # describe #valid?

  describe "#invalid?" do

    context "when the #error is set" do

      it "returns true" do
        expect(subject.invalid?).to eq true
      end

    end # context

    context "when the #error is not set" do

      subject { described_class.new object }

      it "returns false" do
        expect(subject.invalid?).to eq false
      end

    end # context

  end # describe #invalid?

  describe "#messages" do

    context "when the #error is set" do

      it "returns error's messages" do
        expect(subject.messages).to eq messages
      end

    end # context

    context "when the #error is not set" do

      subject { described_class.new object }

      it "returns an empty array" do
        expect(subject.messages).to eq []
      end

    end # context

  end # describe #messages

end # describe Attestor::Report
