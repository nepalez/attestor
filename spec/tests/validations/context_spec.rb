# encoding: utf-8

describe Attestor::Validations::Context do

  let(:klass)   { double validate: nil, validates: nil }
  let(:options) { { except: :foo, only: :bar }         }
  let(:name)    { :baz                                 }
  let(:block)   { proc { :foo }                        }
  subject       { described_class.new klass, options   }

  describe "#klass" do

    it "is initialized" do
      expect(subject.klass).to eq klass
    end

  end # describe #klass

  describe "#options" do

    it "is initialized" do
      expect(subject.options).to eq options
    end

  end # describe #options

  describe "#validate" do

    it "is delegated to klass with name and options" do
      expect(klass).to receive(:validate).with(name, **options)
      subject.validate name
    end

    it "is delegated to klass with a block" do
      expect(klass).to receive(:validate) do |*, &b|
        expect(b).to eq block
      end
      subject.validate(&block)
    end

  end # describe #validate

  describe "#validates" do

    it "is delegated to klass with name and options" do
      expect(klass).to receive(:validates).with(name, **options)
      subject.validates name
    end

    it "is delegated to klass with a block" do
      expect(klass).to receive(:validates) do |*, &b|
        expect(b).to eq block
      end
      subject.validates(&block)
    end

  end # describe #validates

end # describe Attestor::Validations::Context
