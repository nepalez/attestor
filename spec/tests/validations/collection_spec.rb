# encoding: utf-8

describe Attestor::Validations::Collection do

  let(:item_class) { Attestor::Validations::Item }

  describe ".new" do

    it "creates a collection" do
      expect(subject).to be_kind_of Enumerable
    end

    it "creates an immutable object" do
      expect(subject).to be_frozen
    end

  end # .new

  describe "#each" do

    it "returns an enumerator" do
      expect(subject.each).to be_kind_of Enumerator
    end

    it "iterates trough the unique item names" do
      items   = %w(foo bar foo).map(&item_class.method(:new))
      subject = described_class.new items

      expect(subject.to_a).to match_array %i(foo bar)
    end

  end # describe #each

  describe "#add" do

    context "without options" do

      let(:result) { subject.add("foo") }

      it "returns the collection" do
        expect(result).to be_kind_of described_class
      end

      it "adds item to the collection" do
        item = result.first
        expect(item).to eq :foo
      end

      it "preserves existing items" do
        expect(result.add(:bar).to_a).to contain_exactly :foo, :bar
      end

    end # context

    context "with options" do

      let(:result) { subject.add "foo", only: [:foo] }

      it "adds item to the collection" do
        expect(result.to_a).to eq [:foo]
        expect(result.set(:foo).to_a).to eq [:foo]
        expect(result.set(:all).to_a).to eq []
      end

    end # context

    context "existing item" do

      subject { described_class.new.add "foo" }

      it "returns itself" do
        expect(subject.add "foo").to eq subject
      end

    end # context

  end # describe #add

  describe "#context" do

    subject do
      described_class.new
        .add("foo", only:   %w(cad cam))
        .add("bar", except: %w(cad))
        .add("baz", except: %w(cam))
    end

    it "returns a collection" do
      expect(subject.set "all").to be_kind_of described_class
    end

    it "returns a set of items used in given context" do
      expect(subject.set("cad").to_a).to contain_exactly :foo, :baz
      expect(subject.set("cam").to_a).to contain_exactly :foo, :bar
      expect(subject.set("all").to_a).to contain_exactly :bar, :baz
    end

  end # describe #context

end # describe Attestor::Collection
