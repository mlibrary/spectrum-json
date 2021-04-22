# frozen_string_literal: true

require_relative '../spec_helper'
require 'spectrum/item'
require 'spectrum/available_online_holding'

{
  Spectrum::Item => [holdings: Hash.new([]), doc_id: nil, item: Hash.new],
  Spectrum::AvailableOnlineHolding => [nil],
}.each_pair do |klass, args|
  describe klass do
    [
      'doc_id', 'callnumber', 'status', 'location',
      'notes', 'issue', 'can_book?', 'can_reserve?',
      'can_request?', 'circulating?', 'on_shelf?',
      'on_site?', 'off_site?', 'reopened?',
    ].each do |method|
      subject { described_class.new(*args) }
      context "##{method}" do
        it "respond_to? #{method}" do
          expect(subject.respond_to?(method)).to be(true)
        end
      end
    end
  end
end
