# encoding: utf-8

require "support/policies"

describe Attestor::Validations::Delegator do

  let(:validator) { Attestor::Validations::Validator }

  describe ".new" do

    subject { described_class.new "foo" }
    it { is_expected.to be_kind_of validator }

  end # describe .new

  describe "#validate!" do

    let(:object) { double foo: valid_policy }

    context "when initialized without a block" do

      subject { described_class.new "foo" }
      after   { subject.validate! object   }

      it "delegates validation to named method" do
        expect(object).to receive_message_chain(:foo, :validate!)
      end

    end # context

    context "when initialized with a block" do

      subject { described_class.new { foo } }
      after   { subject.validate! object }

      it "delegates validation to block" do
        expect(object).to receive_message_chain(:foo, :validate!)
      end

    end # context

  end # describe #validate!

end # describe Attestor::Validations::Delegator
