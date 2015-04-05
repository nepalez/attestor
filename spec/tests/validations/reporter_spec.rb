# encoding: utf-8

require "support/policies"

describe Attestor::Validations::Reporter do

  let(:object)     { double }
  let(:error)      { Attestor::InvalidError.new object, ["foo"] }
  let(:report)     { Attestor::Report }
  let(:test_class) { Class.new.send(:include, described_class) }

  subject { test_class.new }

  describe "#validate" do

    let(:result) { subject.validate object }

    context "when #validate! fails" do

      before do
        allow(subject).to receive(:validate!).with(object) { fail(error) }
      end

      it "returns an invalid report" do
        expect(result).to be_kind_of report
        expect(result.object).to eq object
        expect(result.error).not_to be_nil
        expect(result.messages).to eq error.messages
      end

    end # context

    context "when #validate! passes" do

      before { allow(subject).to receive(:validate!).with(object) }

      it "returns a valid report" do
        expect(result).to be_kind_of report
        expect(result.object).to eq object
        expect(result.error).to be_nil
      end

    end # context

  end # describe #validate

end # describe Attestor::Validations::Reporter
