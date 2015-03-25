# encoding: utf-8

# Definitions for testing compound policies

def valid_policy
  double valid?: true, invalid?: false
end

def invalid_policy
  double valid?: false, invalid?: true
end

shared_examples "creating a node" do

  it { is_expected.to be_kind_of Attestor::Policy::Node }

end # shared examples

shared_examples "creating an immutable object" do

  it "[freezes a policy]" do
    expect(subject).to be_frozen
  end

end # shared examples

shared_examples "failing validation" do

  it "[raises exception]" do
    expect { subject.validate }.to raise_error Attestor::InvalidError
  end

  it "[adds itself to exception]" do
    begin
      subject.validate
    rescue => error
      expect(error.object).to eq subject
    end
  end

end # shared examples

shared_examples "passing validation" do

  it "[raises exception]" do
    expect { subject.validate }.not_to raise_error
  end

end # shared examples
