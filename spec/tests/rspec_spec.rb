# encoding: utf-8
require "attestor/rspec"

describe Attestor::RSpec do

  let(:report_class)  { Attestor::Report       }
  let(:invalid_error) { Attestor::InvalidError }
  let(:double_class)  { ::RSpec::Mocks::Double }

  subject { Class.new.send(:include, described_class).new }

  describe "#valid_spy" do

    let(:valid_spy) { subject.valid_spy }

    it "returns a spy" do
      expect(valid_spy).to be_kind_of(double_class)
    end

    it "doesn't raise on #validate!" do
      expect { valid_spy.validate! }.not_to raise_error
      expect(valid_spy.validate!).to be_nil
    end

    it "returns a valid report on #validate" do
      report = valid_spy.validate

      expect(report).to be_kind_of(report_class)
      expect(report).to be_valid
      expect(report.object).to eq valid_spy
    end

  end # describe #valid_spy

  describe "#invalid_spy" do

    context "without messages" do

      let(:invalid_spy) { subject.invalid_spy }

      it "returns a spy" do
        expect(invalid_spy).to be_kind_of(double_class)
      end

      it "raises InvalidError on #validate!" do
        expect { invalid_spy.validate! }.to raise_error(invalid_error)
      end

      it "adds itself to the exception on #validate!" do
        begin
          invalid_spy.validate!
        rescue => error
          expect(error.object).to eq invalid_spy
        end
      end

      it "returns a valid report on #validate" do
        report = invalid_spy.validate

        expect(report).to be_kind_of(report_class)
        expect(report).to be_invalid
        expect(report.object).to eq invalid_spy
      end

      it "adds an 'invalid' message to the exception" do
        report = invalid_spy.validate
        expect(report.messages).to eq ["invalid"]
      end

    end # context

    context "with a message" do

      let(:message)     { "error" }
      let(:invalid_spy) { subject.invalid_spy message }

      it "adds the message to the exception" do
        report = invalid_spy.validate
        expect(report.messages).to eq [message]
      end

    end # context

    context "with a list of messages" do

      let(:messages)    { %w(error exception) }
      let(:invalid_spy) { subject.invalid_spy(messages) }

      it "adds all the messages to the exception" do
        report = invalid_spy.validate
        expect(report.messages).to eq messages
      end

    end # context

  end # describe #invalid_spy

end # describe Attestor::RSpec
