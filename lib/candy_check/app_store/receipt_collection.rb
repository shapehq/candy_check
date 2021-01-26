module CandyCheck
  module AppStore
    # Store multiple {Receipt}s in order to perform collective operation on them
    class ReceiptCollection
      # Multiple receipts as in verfication response
      # @return [Array<Receipt>]
      attr_reader :receipts

      # Initializes a new instance which bases on a JSON result
      # from Apple's verification server
      # @param attributes [Array<Hash>]
      def initialize(hash: nil, mapping: nil)
        receipts = if (!mapping.nil?)
          mapping.map do |r|
            Receipt.new(r)
          end
        else
          [Receipt.new(hash)]
       end
        # Sort by purchase date ascending: Older to most recent. Apple _should_ already be sending that
        @receipts = receipts.sort_by!(&purchase_date).reverse!
      end

      # Check if the latest expiration date is passed
      # @return [bool]
      def expired?
        expires_at.to_time <= Time.now.utc
      end

      # Check if in trial
      # @return [bool]
      def trial?
        @receipts.first.is_trial_period
      end

      # Get latest expiration date
      # @return [DateTime]
      def expires_at
        @receipts.first.expires_date
      end

      # Get number of overdue days. If this is negative, it is not overdue.
      # @return [Integer]
      def overdue_days
        (Date.today - expires_at.to_date).to_i
      end
    end
  end
end
