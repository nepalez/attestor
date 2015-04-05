# encoding: utf-8

describe Attestor::Validations::Validators do

  let(:validator_class) { Attestor::Validations::Validator }
  let(:delegator_class) { Attestor::Validations::Delegator }
  let(:reporter_module) { Attestor::Validations::Reporter  }
  let(:invalid_error)   { Attestor::InvalidError           }

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

    context "with a name" do

      let(:result) { subject.add_validator "foo" }

      it "returns validators" do
        expect(result).to be_kind_of described_class
      end

      it "adds validator (not a delegator)" do
        item = result.first
        expect(item).to be_kind_of validator_class
        expect(item).not_to be_kind_of delegator_class
      end

      it "assigns a name" do
        item = result.first
        expect(item.name).to eq :foo
      end

      it "preserves existing items" do
        expect(result.add_validator(:bar).count).to be 2
      end

    end # context

    context "with a block" do

      let(:block)  { proc { foo } }
      let(:result) { subject.add_validator(&block) }

      it "returns validators" do
        expect(result).to be_kind_of described_class
      end

      it "adds a validator (not a delegator)" do
        item = result.first
        expect(item).to be_kind_of validator_class
        expect(item).not_to be_kind_of delegator_class
      end

      it "assigns a block to the validator" do
        item = result.first
        expect(item.block).to eq block
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

  end # describe #add_validator

  describe "#add_delegator" do

    context "with a name" do

      let(:result) { subject.add_delegator "foo" }

      it "returns validators" do
        expect(result).to be_kind_of described_class
      end

      it "adds a delegator" do
        item = result.first
        expect(item).to be_kind_of delegator_class
      end

      it "assigns a name" do
        item = result.first
        expect(item.name).to eq :foo
      end

      it "preserves existing items" do
        expect(result.add_delegator(:bar).count).to eq 2
      end

    end # context

    context "with a block" do

      let(:block)  { proc { foo } }
      let(:result) { subject.add_delegator(&block) }

      it "returns validators" do
        expect(result).to be_kind_of described_class
      end

      it "adds a delegator" do
        item = result.first
        expect(item).to be_kind_of delegator_class
      end

      it "assigns a block to the delegator" do
        item = result.first
        expect(item.block).to eq block
      end

    end # context

    context "with contexts" do

      let(:result) { subject.add_delegator "foo", only: [:foo] }

      it "adds item to validators" do
        expect(result.map(&:name)).to eq [:foo]
        expect(result.set(:foo).map(&:name)).to eq [:foo]
        expect(result.set(:all).map(&:name)).to eq []
      end

    end # context

  end # describe #add_delegator

  describe "#set" do

    subject do
      described_class.new
        .add_validator("foo")
        .add_validator("bar", except: %w(cad))
        .add_validator("baz", except: %w(cam))
    end

    it "returns a collection" do
      expect(subject.set "all").to be_kind_of described_class
    end

    it "returns a set of items used in given context" do
      expect(subject.set("cad").map(&:name)).to contain_exactly :foo, :baz
      expect(subject.set("cam").map(&:name)).to contain_exactly :foo, :bar
      expect(subject.set("all").map(&:name)).to contain_exactly :foo, :bar, :baz
    end

  end # describe #set

  describe "#validate!" do

    let(:object) { double foo: nil, bar: nil }

    subject do
      described_class.new
        .add_validator("foo")
        .add_validator("bar")
    end

    context "when all validators passes" do

      it "calls all validators" do
        expect(object).to receive :foo
        expect(object).to receive :bar
        subject.validate! object
      end

      it "passes" do
        expect { subject.validate! object }.not_to raise_error
      end

    end # context

    context "when any validator fails" do

      let(:messages) { %w(foo) }
      before do
        allow(object)
          .to receive(:foo) { fail invalid_error.new(object, messages) }
      end

      it "calls all validators" do
        expect(object).to receive :foo
        expect(object).to receive :bar
        subject.validate! object rescue nil
      end

      it "fails" do
        expect { subject.validate! object }.to raise_error(invalid_error)
      end

      it "collects errors from validators" do
        begin
          subject.validate! object
        rescue => error
          expect(error.object).to   eq object
          expect(error.messages).to eq messages
        end
      end

    end # context

  end # describe #validate!

  describe "#validate" do

    it "is is imported from the Reporter" do
      expect(described_class).to include reporter_module
    end

  end # describe #validate

end # describe Attestor::Validators
