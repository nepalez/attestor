# encoding: utf-8

require "support/policies"

describe Attestor::Validations::Follower do

  let(:validator) { Attestor::Validations::Validator }
  subject { described_class.new "foo" }

  describe ".new" do

    it { is_expected.to be_kind_of validator }

  end # describe .new

  describe "#validate" do

    after { subject.validate object }

    context "when a policy is valid" do

      let(:object) { double foo: valid_policy }

      it "calls policy method and passes" do
        expect(object).to receive :foo
        expect(object).not_to receive :invalid
      end

    end # context

    context "when a policy is invalid" do

      let(:object) { double foo: invalid_policy }

      it "calls policy method and fails" do
        expect(object).to receive :foo
        expect(object).to receive(:invalid).with(:foo)
      end

    end # context

  end # describe #validate

end # describe Attestor::Validations::Follower
