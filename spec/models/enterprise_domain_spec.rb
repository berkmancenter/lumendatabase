require 'spec_helper'

describe EnterpriseDomain do
  describe '.normalize' do
    it 'normalizes URLs to host names' do
      expect(described_class.normalize('https://Example.COM/path?q=1')).to eq 'example.com'
    end

    it 'normalizes wildcard domains' do
      expect(described_class.normalize('*.example.com')).to eq 'example.com'
    end
  end

  describe '.matches_url?' do
    it 'matches exact hosts and subdomains' do
      expect(described_class.matches_url?('https://example.com/a', ['example.com'])).to be true
      expect(described_class.matches_url?('https://cdn.example.com/a', ['example.com'])).to be true
    end

    it 'does not match sibling domains by substring' do
      expect(described_class.matches_url?('https://badexample.com/a', ['example.com'])).to be false
    end
  end
end
