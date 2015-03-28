# encoding: utf-8

describe Attestor::Validations::Validators do

  let(:validator_class) { Attestor::Validations::Validator }
  let(:follower_class)  { Attestor::Validations::Follower  }

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

    it "iterates trough validators" do
      validators = %w(foo bar foo).map(&validator_class.method(:new))
      subject = described_class.new validators

      expect(subject.to_a).to match_array validators
    end

  end # describe #each

  describe "#add_validator" do

    context "without contexts" do

      let(:result) { subject.add_validator "foo" }

      it "returns validators" do
        expect(result).to be_kind_of described_class
      end

      it "adds validator (not a follower)" do
        item = result.first
        expect(item).to be_kind_of validator_class
        expect(item).not_to be_kind_of follower_class
      end

      it "assigns a name" do
        item = result.first
        expect(item.name).to eq :foo
      end

      it "preserves existing items" do
        expect(result.add_validator(:bar).map(&:name))
          .to contain_exactly :foo, :bar
      end

    end # context

    context "with contexts" do

      let(:result) { subject.add_validator "foo", only: [:foo] }

      it "adds item to validators" do
        expect(result.map(&:name)).to eq [:foo]
        expect(result.set(:foo).map(&:name)).to eq [:foo]
        expect(result.set(:all).map(&:name)).to eq []
      end

    end # context

    context "existing validator" do

      subject { described_class.new.add_validator "foo" }

      it "returns itself" do
        expect(subject.add_validator "foo").to eq subject
      end

    end # context

  end # describe #add_validator

  describe "#add_follower" do

    context "without contexts" do

      let(:result) { subject.add_follower "foo" }

      it "returns validators" do
        expect(result).to be_kind_of described_class
      end

      it "adds a follower" do
        item = result.first
        expect(item).to be_kind_of follower_class
      end

      it "assigns a name" do
        item = result.first
        expect(item.name).to eq :foo
      end

      it "preserves existing items" do
        expect(result.add_follower(:bar).map(&:name))
          .to contain_exactly :foo, :bar
      end

    end # context

    context "with contexts" do

      let(:result) { subject.add_follower "foo", only: [:foo] }

      it "adds item to validators" do
        expect(result.map(&:name)).to eq [:foo]
        expect(result.set(:foo).map(&:name)).to eq [:foo]
        expect(result.set(:all).map(&:name)).to eq []
      end

    end # context

    context "existing validator" do

      subject { described_class.new.add_follower "foo" }

      it "returns itself" do
        expect(subject.add_follower "foo").to eq subject
      end

    end # context

  end # describe #add_follower

  describe "#set" do

    subject do
      described_class.new
        .add_validator("foo", only:   %w(cad cam))
        .add_validator("bar", except: %w(cad))
        .add_validator("baz", except: %w(cam))
    end

    it "returns a collection" do
      expect(subject.set "all").to be_kind_of described_class
    end

    it "returns a set of items used in given context" do
      expect(subject.set("cad").map(&:name)).to contain_exactly :foo, :baz
      expect(subject.set("cam").map(&:name)).to contain_exactly :foo, :bar
      expect(subject.set("all").map(&:name)).to contain_exactly :bar, :baz
    end

  end # describe #set

end # describe Attestor::Validators
