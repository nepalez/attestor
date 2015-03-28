# encoding: utf-8

describe Attestor::InvalidError do

  let(:object) { double :object }
  subject      { described_class.new object }

  describe ".new" do

    it "creates a RuntimeError" do
      expect(subject).to be_kind_of RuntimeError
    end

    it "creates immutable object" do
      expect(subject).to be_frozen
    end

    it "doesn't freeze object" do
      subject
      expect(object).not_to be_frozen
    end

    it "doesn't freeze messages" do
      messages = %i(foo bar)
      described_class.new object, messages

      expect(messages).not_to be_frozen
    end

  end # describe .new

  describe "#object" do

    it "is initialized" do
      expect(subject.object).to be_eql object
    end

  end # describe #object

  describe "#messages" do

    it "returns an empty array" do
      expect(subject.messages).to eq []
    end

    it "can be initialized" do
      subject = described_class.new(object, %w(cad cam))
      expect(subject.messages).to eq %w(cad cam)
    end

  end # describe #messages

end # describe Attestor::ValidError
