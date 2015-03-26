# encoding: utf-8

require "support/policies"

describe Attestor::Validations::Validator do

  subject { described_class.new "foo" }

  describe ".new" do

    it "is immutable" do
      expect(subject).to be_frozen
    end

    it "accepts item option :except" do
      expect { described_class.new "foo", except: :bar }.not_to raise_error
    end

    it "accepts array option :except" do
      expect { described_class.new "foo", except: %w(bar) }.not_to raise_error
    end

    it "ignores repetitive :except items" do
      expect(described_class.new "foo", except: %i(bar bar))
        .to eq(described_class.new "foo", except: %i(bar))
    end

    it "accepts item option :only" do
      expect { described_class.new "foo", only: :bar }.not_to raise_error
    end

    it "accepts array option :only" do
      expect { described_class.new "foo", only: %w(bar) }.not_to raise_error
    end

    it "ignores repetitive :only items" do
      expect(described_class.new "foo", only: %i(bar bar))
        .to eq(described_class.new "foo", only: %i(bar))
    end

    it "accepts array option :policy" do
      expect { described_class.new "foo", policy: :bar }.not_to raise_error
    end

  end # describe .new

  describe "#name" do

    it "is initialized as a symbol" do
      expect(subject.name).to eq :foo
    end

  end # describe .name

  describe "#policy?" do

    it "is set to false by default" do
      expect(subject.policy?).to eq false
    end

    it "can be initialized" do
      subject = described_class.new "foo", policy: 1
      expect(subject.policy?).to eq true
    end

  end # describe #policy?

  describe "#==" do

    subject { described_class.new :foo, except: [:foo], only: %i(bar) }

    context "item with the same arguments" do

      let(:other) { described_class.new :foo, except: %i(foo), only: %i(bar) }

      it "returns true" do
        expect(subject == other).to eq true
        expect(subject).to eq other
      end

    end # context

    context "item with another name" do

      let(:other) { described_class.new :baz, except: %i(foo), only: %i(bar) }

      it "returns false" do
        expect(subject == other).to eq false
        expect(subject).not_to eq other
      end

    end # context

    context "item with another blacklist" do

      let(:other) { described_class.new :foo, except: %i(baz), only: %i(bar) }

      it "returns false" do
        expect(subject == other).to eq false
        expect(subject).not_to eq other
      end

    end # context

    context "item with another whitelist" do

      let(:other) { described_class.new :foo, except: %i(foo), only: %i(baz) }

      it "returns false" do
        expect(subject == other).to eq false
        expect(subject).not_to eq other
      end

    end # context

    context "not an item" do

      let(:other) { "baz" }

      it "returns false" do
        expect(subject == other).to eq false
        expect(subject).not_to eq other
      end

    end # context

  end # describe #==

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

  describe "#validate" do

    after { subject.validate object }

    context "when a #policy isn't set" do

      let(:object) { double foo: nil }
      subject { described_class.new :foo }

      it "calls validation method" do
        expect(object).to receive :foo
      end

    end # context

    context "when a #policy is set to valid policy" do

      let(:object) { double foo: valid_policy }
      subject { described_class.new :foo, policy: true }

      it "calls policy method" do
        expect(object).to receive(:foo)
      end

      it "doesn't call #invalid" do
        expect(object).not_to receive(:invalid)
      end

    end # context

    context "when a #policy is set to valid policy" do

      let(:object) { double foo: invalid_policy, invalid: nil }
      subject { described_class.new :foo, policy: true }

      it "calls policy method" do
        expect(object).to receive(:foo)
      end

      it "calls #invalid with name" do
        expect(object).to receive(:invalid).with(:foo)
      end

    end # context

  end # describe #validate

end # describe Attestor::Validation