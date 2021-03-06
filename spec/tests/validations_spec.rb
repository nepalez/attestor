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

    context "with a name" do

      before { test_class.validate :foo }

      it "registers a validator" do
        item = test_class.validators.first
        expect(item).to be_kind_of validator_class
        expect(item).not_to be_kind_of delegator_class
      end

      it "assigns the name to the validator" do
        item = test_class.validators.first
        expect(item.name).to eq :foo
      end

    end # context

    context "with a block" do

      let(:block) { proc { foo } }
      before      { test_class.validate(&block) }

      it "registers a validator" do
        item = test_class.validators.first
        expect(item).to be_kind_of validator_class
        expect(item).not_to be_kind_of delegator_class
      end

      it "assigns the block to the validator" do
        item = test_class.validators.first
        expect(item.block).to eq block
      end

    end # context

    context "with options" do

      before { test_class.validate :foo, only: %w(bar baz), except: "bar" }

      it "uses options" do
        expect(test_class.validators.map(&:name)).to eq [:foo]
        expect(test_class.validators.set(:baz).map(&:name)).to eq [:foo]
        expect(test_class.validators.set(:bar).map(&:name)).to eq []
      end

    end # context

  end # describe .validate

  describe ".validates" do

    context "with a name" do

      before { test_class.validates :foo }

      it "registers a delegator" do
        item = test_class.validators.first
        expect(item).to be_kind_of delegator_class
      end

      it "assigns the name to the delegator" do
        item = test_class.validators.first
        expect(item.name).to eq :foo
      end

    end # context

    context "with a block" do

      let(:block) { proc { foo } }
      before      { test_class.validates(&block) }

      it "registers a delegator" do
        item = test_class.validators.first
        expect(item).to be_kind_of delegator_class
      end

      it "assigns the block to the delegator" do
        item = test_class.validators.first
        expect(item.block).to eq block
      end

    end # context

    context "with options" do

      before { test_class.validates :foo, only: %w(bar baz), except: "bar" }

      it "uses options" do
        expect(test_class.validators.map(&:name)).to eq [:foo]
        expect(test_class.validators.set(:baz).map(&:name)).to eq [:foo]
        expect(test_class.validators.set(:bar).map(&:name)).to eq []
      end

    end # context

  end # describe .validates

  describe ".validations" do

    let(:options)       { { only: :bar, except: :baz }         }
    let(:context_class) { Attestor::Validations::Context       }
    let(:context)       { double validate: nil, validates: nil }
    before { allow(context_class).to receive(:new) { context } }

    context "with a block" do

      after { test_class.validations(options) { validate :foo } }

      it "initializes a context group" do
        expect(context_class).to receive(:new).with(test_class, options)
      end

      it "calls the block in a context's scope" do
        expect(context).to receive(:validate).with(:foo)
      end

    end # context

    context "without a block" do

      after { test_class.validations(options) }

      it "does nothing" do
        expect(context_class).not_to receive(:new)
      end

    end # context

  end # describe .validations

  describe "#invalid" do

    shared_examples "raising an error" do |name, options = {}|

      let(:message) { double }
      before do
        allow(message_class)
          .to receive(:new)
          .with(name, subject, options)
          .and_return message
      end

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

  describe "#validate!" do

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
        subject.validate!
      end

    end # context

    context ":foo" do

      it "calls validators for :foo context" do
        expect(subject).to receive(:foo)
        expect(subject).to receive(:baz)
        expect(subject).not_to receive(:bar)
        subject.validate! :foo
      end

    end # context

  end # describe #validate!

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

  end # describe #validate!

end # describe Attestor::Validations
