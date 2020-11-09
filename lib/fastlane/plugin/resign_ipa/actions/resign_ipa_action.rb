# frozen_string_literal: true

require 'fastlane/action'
require_relative '../helper/resign_ipa_helper'

module Fastlane
  module Actions
    class ResignIpaAction < Action
      require 'base64'
      require 'openssl'
      require 'plist'
      require 'tempfile'

      def self.run(params)
        info_plist = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file(params[:ipa])

        table = Terminal::Table.new(
          title: 'App to Resign',
          headings: ['Key', 'Value'],
          rows: FastlaneCore::PrintTable.transform_output(
            info_plist.select do |k, _|
              [
                'CFBundleIdentifier',
                'CFBundleDisplayName',
                'CFBundleShortVersionString',
                'CFBundleVersion'
              ].include?(k)
            end
          )
        )
        UI.message("\n#{table}\n")

        app_identifier = info_plist['CFBundleIdentifier']
        other_action.match(
          type: 'adhoc',
          app_identifier: app_identifier,
          readonly: true
        )

        UI.message("Sigh profile type: #{lane_context[SharedValues::SIGH_PROFILE_TYPE]}")

        sigh_profile_type = {
          'ad-hoc' => 'adhoc',
          'app-store' => 'appstore',
          'development' => 'development',
          'enterprise' => 'enterprise',
          'developer-id' => 'developer_id'
        }[lane_context[SharedValues::SIGH_PROFILE_TYPE]]

        env_name = "sigh_#{app_identifier}_#{sigh_profile_type}_profile-path"
        UI.message("Looking up profile path from \"#{env_name}\"")
        profile_path = ENV[env_name]
        UI.user_error!("missing provisioning profile for #{app_identifier}") unless profile_path
        UI.success("Using profile: \"#{profile_path}\"")

        # http://maniak-dobrii.com/extracting-stuff-from-provisioning-profile/
        raw_mobile_provision = `security cms -D -i "#{profile_path}"`
        mobileprovision = Plist.parse_xml(raw_mobile_provision)
        # https://ruby-doc.org/stdlib-2.5.3/libdoc/openssl/rdoc/OpenSSL/X509/Certificate.html
        certificate = OpenSSL::X509::Certificate.new(mobileprovision['DeveloperCertificates'][0].string)
        common_name = certificate.subject.to_a.select { |name, _, _| name == 'CN' }.first[1]
        UI.user_error!('Unable to extract signing identity from mobileprovision file') unless common_name

        entitlements = mobileprovision['Entitlements']
        UI.user_error!('Unable to extract entitlements from mobileprovision file') unless entitlements

        Tempfile.create do |entitlements_file|
          entitlements_file << entitlements.to_plist
          entitlements_file.flush

          other_action.resign(
            ipa: params[:ipa],
            signing_identity: common_name,
            provisioning_profile: profile_path,
            entitlements: entitlements_file.path
          )
        end
      end

      def self.description
        "Resign an ipa with a new provisioning profile pulled by Fastlane Match"
      end

      def self.authors
        ["Micah Rosales"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :ipa,
            env_name: "RESIGN_IPA_FILE",
            description: "Path to the ipa file to sign",
            optional: false,
            type: String
          )
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
