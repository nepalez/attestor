# encoding: utf-8

describe Attestor::Validations::Message do

  let(:test_class) { Class.new }
  before { TestModule = Module.new }
  before { TestModule::TestObject = test_class }
  after  { Object.send :remove_const, :TestModule }

  let(:scope) { test_class.new }

  shared_examples "building frozen string" do

    it { is_expected.to be_kind_of String }
    it { is_expected.to be_frozen }

  end # shared examples

  describe ".new" do

    context "with a symbol argument" do

      subject { described_class.new :invalid, scope, foo: "bar" }

      it_behaves_like "building frozen string"

      it "translates the symbol in given scope" do
        expect(I18n).to receive(:t) do |text, options|
          expect(text).to eq :invalid
          expect(options[:scope])
            .to eq %w(attestor errors test_module/test_object)
          expect(options[:default]).to eq "#{ scope } is invalid (invalid)"
          expect(options[:foo]).to eq "bar"
          ""
        end
        subject
      end

      it "returns the translation" do
        expect(subject).to eq "#{ scope } is invalid (invalid)"
      end

    end # context

    context "with a non-symbolic argument" do

      subject { described_class.new 1, scope }

      it_behaves_like "building frozen string"

      it "creates a stringified argument" do
        expect(subject).to eq "1"
      end

    end # context

    context "without options" do

      subject { described_class.new :invalid, scope }

      it_behaves_like "building frozen string"

      it "returns the translation" do
        expect(subject).to eq "#{ scope } is invalid (invalid)"
      end

    end # context

  end # describe .new

end # Attestor::Validations::Invalid
