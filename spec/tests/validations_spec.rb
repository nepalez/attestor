# encoding: utf-8

require "support/policies" # for #valid_policy and #invalid_policy definitions

describe Attestor::Validations do

  let(:validators_class) { Attestor::Validations::Validators }
  let(:validator_class)  { Attestor::Validations::Validator  }
  let(:delegator_class)  { Attestor::Validations::Delegator  }
  let(:item_class)       { Attestor::Validations::Item       }
  let(:message_class)    { Attestor::Validations::Message    }
  let(:invalid_error)    { Attestor::InvalidError            }

  let(:test_class) { Class.new.send(:include, described_class) }
  before           { Test = test_class                         }
  after            { Object.send :remove_const, :Test          }

  subject { test_class.new }

  describe ".validators" do

    it "returns Validators" do
      expect(test_class.validators).to be_kind_of validators_class
    end

    it "is empty by default" do
      expect(test_class.validators.to_a).to be_empty
    end

  end # describe .validators

  describe ".validate" do

    context "without options" do

      before { test_class.validate :foo }

      it "registers a validator" do
        expect(test_class.validators.map(&:name)).to eq [:foo]
        expect(test_class.validators.first).not_to be_kind_of delegator_class
      end

    end # context

    context "with restrictions" do

      before { test_class.validate :foo, only: %w(bar baz), except: "bar" }

      it "uses options" do
        expect(test_class.validators.map(&:name)).to eq [:foo]
        expect(test_class.validators.set(:baz).map(&:name)).to eq [:foo]
        expect(test_class.validators.set(:bar).map(&:name)).to eq []
      end

    end # context

  end # describe .validate

  describe ".validates" do

    context "without options" do

      before { test_class.validates :foo }

      it "registers a delegator" do
        expect(test_class.validators.map(&:name)).to eq [:foo]
        expect(test_class.validators.first).to be_kind_of delegator_class
      end

    end # context

    context "with restrictions" do

      before { test_class.validates :foo, only: %w(bar baz), except: "bar" }

      it "uses options" do
        expect(test_class.validators.map(&:name)).to eq [:foo]
        expect(test_class.validators.set(:baz).map(&:name)).to eq [:foo]
        expect(test_class.validators.set(:bar).map(&:name)).to eq []
      end

    end # context

  end # describe .validates

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

  describe "#validate" do

    before do
      test_class.validate  :foo
      test_class.validate  :bar, only: :all
      test_class.validates :baz, only: :foo

      allow(subject).to receive(:foo)
      allow(subject).to receive(:bar)
      allow(subject).to receive(:baz) { valid_policy }
    end

    context "without an argument" do

      it "calls validators for :all context" do
        expect(subject).to receive(:foo)
        expect(subject).to receive(:bar)
        expect(subject).not_to receive(:baz)
        subject.validate
      end

    end # context

    context ":foo" do

      it "calls validators for :foo context" do
        expect(subject).to receive(:foo)
        expect(subject).to receive(:baz)
        expect(subject).not_to receive(:bar)
        subject.validate :foo
      end

    end # context

  end # describe #validate

end # describe Attestor::Validations
