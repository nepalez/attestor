# encoding: utf-8

describe "Base example" do

  before do
    Account     = Struct.new(:client, :limit)
    Transaction = Struct.new(:account, :sum)

    class ConsistencyPolicy < Struct.new(:debet, :credit)
      include Attestor::Policy

      validate :consistent

      private

      def consistent
        return if debet.sum + credit.sum == 0
        invalid :inconsistent
      end
    end

    class LimitPolicy < Struct.new(:transaction)
      include Attestor::Policy

      validate :limited

      private

      def limited
        return unless (transaction.account.limit + transaction.sum) < 0
        invalid :over_the_limit
      end
    end

    class InternalTransfer < Struct.new(:debet, :credit)
      include Attestor::Policy

      validate :internal

      private

      def internal
        return if debet.account.client == credit.account.client
        invalid :external
      end
    end

    class Transfer < Struct.new(:debet, :credit)
      include Attestor::Validations

      validate :internal, only: :blocked
      validate :consistent
      validate :limited

      private

      def internal
        invalid :external if internal_transfer.invalid?
      end

      def consistent
        invalid :inconsistent if ConsistencyPolicy.new(debet, credit).invalid?
      end

      def limited
        return if internal_transfer.or(LimitPolicy.new(debet)).valid?
        invalid :over_the_limit
      end

      def internal_transfer
        InternalTransfer.new(debet, credit)
      end
    end
  end

  let(:alice) { Account.new("Alice", 100) }
  let(:bob)   { Account.new("Bob", 100) }

  let(:a_to_a) do
    Transfer.new Transaction.new(alice, -150), Transaction.new(alice, 150)
  end

  let(:a_to_b) do
    Transfer.new Transaction.new(alice, -150), Transaction.new(bob, 150)
  end

  let(:b_to_a) do
    Transfer.new Transaction.new(bob, -50), Transaction.new(alice, 50)
  end

  it "works fine" do
    expect { a_to_a.validate }.not_to raise_error
    expect { a_to_b.validate }.to raise_error
    expect { b_to_a.validate }.not_to raise_error
    expect { b_to_a.validate :blocked }.to raise_error
  end

  after do
    %w(
      Transfer
      InternalTransfer
      LimitPolicy
      ConsistencyPolicy
      Transaction
      Account
    ).each { |klass| Object.send :remove_const, klass }
  end
end
