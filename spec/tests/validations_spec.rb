# encoding: utf-8

describe Attestor::Validations do

  let(:validators_class) { Attestor::Validations::Validators }
  let(:validator_class)  { Attestor::Validations::Validator }
  let(:message_class)    { Attestor::Validations::Message }
  let(:invalid_error)    { Attestor::InvalidError }
  let(:test_class)       { Class.new.send(:include, described_class) }

  before { Test = test_class }
  after  { Object.send :remove_const, :Test }

  subject { test_class.new }

  describe ".validations" do

    it "returns Validators" do
      expect(test_class.validations).to be_kind_of validators_class
    end

    it "is empty by default" do
      expect(test_class.validations.to_a).to be_empty
    end

  end # describe .validations

  describe ".validate" do

    context "without options" do

      before { test_class.validate :foo }

      it "registers a validator" do
        expect(test_class.validations.to_a).to eq [:foo]
      end

    end # context

    context "with options" do

      before { test_class.validate :foo, only: %w(bar baz), except: "bar" }

      it "uses options" do
        expect(test_class.validations.to_a).to eq [:foo]
        expect(test_class.validations.set(:baz).to_a).to eq [:foo]
        expect(test_class.validations.set(:bar).to_a).to eq []
      end

    end # context

  end # describe .validate

  describe "#validate" do

    before do
      test_class.validate :foo
      test_class.validate :bar, only: :all
      test_class.validate :baz, only: :foo
      %i(foo bar baz).each { |method| allow(subject).to receive(method) }
    end

    context "without an argument" do

      it "calls validations for :all context" do
        expect(subject).to receive(:foo)
        expect(subject).to receive(:bar)
        expect(subject).not_to receive(:baz)
        subject.validate
      end

    end # context

    context ":foo" do

      it "calls validations for :foo context" do
        expect(subject).to receive(:foo)
        expect(subject).to receive(:baz)
        expect(subject).not_to receive(:bar)
        subject.validate :foo
      end

    end # context

  end # describe #validate

  describe "#invalid" do

    shared_examples "raising an error" do |name, options = {}|

      let(:message) { message_class.new(name, subject, options) }

      it "raises an InvalidError" do
        expect { invalid }.to raise_error invalid_error
      end

      it "assings itself to the exception" do
        begin
          invalid
        rescue => error
          expect(error.object).to eq subject
          expect(error.messages).to contain_exactly message
        end
      end

    end # shared examples

    context "without options" do

      let(:invalid) { subject.invalid :foo }

      it_behaves_like "raising an error", :foo

    end

    context "with options" do

      let(:invalid) { subject.invalid :foo, bar: :baz }

      it_behaves_like "raising an error", :foo, bar: :baz

    end

  end # invalid

end # describe Attestor::Validations
