require 'spec_helper'

describe NormalizesParameters do

  context 'with infringing_urls parameters' do
    it "modifies correctly when given \\n separated urls" do
      params = example_params_with_infringing_urls("foo\nbar")
      described_class.normalize(params)

      expect(
        params[:submission][:works][0][:infringing_urls]
      ).to eq ['foo','bar']
    end

    it "modifies correctly when given \\r\\n separated urls" do
      params = example_params_with_infringing_urls("foo\r\nbar")
      described_class.normalize(params)

      expect(
        params[:submission][:works][0][:infringing_urls]
      ).to eq ['foo','bar']
    end
  end

  context 'without infringing_urls parameter' do
    it 'does not modify the params' do
      params = { submission: {} }
      described_class.normalize(params)

      expect(params).to eq params
    end
  end

  private

  def example_params_with_infringing_urls(infringing_urls_parameter)
    {submission: { works: [{ infringing_urls: infringing_urls_parameter }] } }
  end
end
