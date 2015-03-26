# encoding: utf-8

describe "Base example" do

  before do
    Account     = Struct.new(:client, :limit)
    Transaction = Struct.new(:account, :sum)
    Transfer    = Struct.new(:debet, :credit)

    ConsistencyPolicy = Struct.new(:debet, :credit)
    LimitPolicy       = Struct.new(:transaction)
    InternalTransfer  = Struct.new(:debet, :credit)

    class ConsistencyPolicy
      include Attestor::Policy

      validate :consistent

      private

      def consistent
        return if debet.sum + credit.sum == 0
        invalid :inconsistent
      end
    end

    class LimitPolicy
      include Attestor::Policy

      validate :limited

      private

      def limited
        return unless (transaction.account.limit + transaction.sum) < 0
        invalid :over_the_limit
      end
    end

    class InternalTransfer
      include Attestor::Policy

      validate :internal

      private

      def internal
        return if debet.account.client == credit.account.client
        invalid :external
      end
    end

    class Transfer
      include Attestor::Validations

      follow_policy :consistent
      follow_policy :limited, except: :blocked
      follow_policy :internal,  only: :blocked

      private

      def consistent
        ConsistencyPolicy.new(debet, credit)
      end

      def limited
        LimitPolicy.new(debet).or internal
      end

      def internal
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
    expect { b_to_a.validate }.not_to raise_error

    expect { a_to_b.validate }.to raise_error Attestor::InvalidError
    expect { b_to_a.validate :blocked }.to raise_error Attestor::InvalidError
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
