# encoding: utf-8

require "support/policies"

describe Attestor::Validations::Validator do

  let(:reporter_module) { Attestor::Validations::Reporter }
  subject { described_class.new "foo" }

  describe ".new" do

    it "is immutable" do
      expect(subject).to be_frozen
    end

  end # describe .new

  describe "#name" do

    it "is initialized as a symbol" do
      expect(subject.name).to eq :foo
    end

    it "is initialized by default as :invalid" do
      expect(described_class.new.name).to eq :invalid
    end

  end # describe .name

  describe "#whitelist" do

    it "returns an empty array by default" do
      expect(subject.whitelist).to eq []
    end

    it "is initialized" do
      subject = described_class.new("foo", only: :bar)
      expect(subject.whitelist).to eq [:bar]
    end

    it "is symbolized" do
      subject = described_class.new("foo", only: %w(bar baz))
      expect(subject.whitelist).to eq [:bar, :baz]
    end

    it "contains unique items" do
      subject = described_class.new("foo", only: %i(bar bar))
      expect(subject.whitelist).to eq [:bar]
    end

  end # describe .whitelist

  describe "#blacklist" do

    it "returns an empty array by default" do
      expect(subject.blacklist).to eq []
    end

    it "is initialized" do
      subject = described_class.new("foo", except: :bar)
      expect(subject.blacklist).to eq [:bar]
    end

    it "is symbolized" do
      subject = described_class.new("foo", except: %w(bar baz))
      expect(subject.blacklist).to eq [:bar, :baz]
    end

    it "contains unique items" do
      subject = described_class.new("foo", except: %i(bar bar))
      expect(subject.blacklist).to eq [:bar]
    end

  end # describe .blacklist

  describe "#block" do

    it "returns nil by default" do
      expect(subject.block).to be_nil
    end

    it "is initialized" do
      block = proc { :foo }
      subject = described_class.new "foo", &block
      expect(subject.block).to eq block
    end

  end # describe .blacklist

  describe "#used_in_context?" do

    context "not restricted" do

      it { is_expected.to be_used_in_context :bar }
      it { is_expected.to be_used_in_context "baz" }

    end # context

    context "blacklisted" do

      subject { described_class.new "foo", except: %w(foo bar) }

      it { is_expected.not_to be_used_in_context "foo" }
      it { is_expected.not_to be_used_in_context :bar }
      it { is_expected.to be_used_in_context "baz" }

    end # context

    context "whitelisted" do

      subject { described_class.new "foo", only: %w(foo bar) }

      it { is_expected.to be_used_in_context "foo" }
      it { is_expected.to be_used_in_context :bar }
      it { is_expected.not_to be_used_in_context "baz" }

    end # context

    context "white- and blacklisted" do

      subject do
        described_class.new "foo", only: %w(foo bar), except: %w(bar baz)
      end

      it { is_expected.to be_used_in_context "foo" }
      it { is_expected.not_to be_used_in_context :bar }
      it { is_expected.not_to be_used_in_context "baz" }

    end

  end # describe #name

  describe "#validate!" do

    let(:object) { Class.new { private def foo; end }.new }
    after        { subject.validate! object }

    context "when no block initialized" do

      subject { described_class.new :foo }

      it "calls validation method" do
        expect(object).to receive :foo
      end

    end # context

    context "when block initialized" do

      subject { described_class.new(:baz) { foo } }

      it "calls a block" do
        expect(object).to receive :foo
      end

    end # context

  end # describe #validate!

  describe "#validate" do

    it "is is imported from the Reporter" do
      expect(described_class).to include reporter_module
    end

  end # describe #validate

end # describe Attestor::Validation
