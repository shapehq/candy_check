module CandyCheck
  module AppStore
    # Verifies a latest_receipt_info block against a verification server.
    # The call return either an {ReceiptCollection} or a {VerificationFailure}
    class SubscriptionVerification < CandyCheck::AppStore::Verification
      # Performs the verification against the remote server
      # @return [ReceiptCollection] if successful
      # @return [VerificationFailure] otherwise
      def call!
        verify!
        if valid?
          if @response['latest_receipt_info'].is_a? Hash
            ReceiptCollection.new(hash: @response['latest_receipt_info'])
          else
            ReceiptCollection.new(mapping: @response['latest_receipt_info'])
          end
        else
          VerificationFailure.fetch(@response['status'])
        end
      end

      private

      def valid?
        status_is_ok = @response['status'] == STATUS_OK
        @response && status_is_ok && @response['latest_receipt_info']
      end
    end
  end
end

