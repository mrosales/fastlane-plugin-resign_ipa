# frozen_string_literal: true

describe Fastlane::Actions::ResignIpaAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with('The resign_ipa plugin is working!')

      Fastlane::Actions::ResignIpaAction.run(nil)
    end
  end
end
