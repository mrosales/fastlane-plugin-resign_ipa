# frozen_string_literal: true

require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?('UI')

  module Helper
    class ResignIpaHelper
      # class methods that you define here become available in your action
      # as `Helper::ResignIpaHelper.your_method`
      #
      def self.show_message
        UI.message('Hello from the resign_ipa plugin helper!')
      end
    end
  end
end
