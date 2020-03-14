# frozen_string_literal: true

module AsciiDocPublishingToolbox
  VERSION = '0.1.0.alpha'

  def self.adpt_major_version
    @adpt_major_version ||= VERSION.split('.').first.to_i
  end
end
