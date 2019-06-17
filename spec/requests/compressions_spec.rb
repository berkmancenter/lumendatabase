require 'rails_helper'

RSpec.describe "Compressions", type: :request do
  describe Rack::Deflater do

    it "compresses response if requested" do
    	[root_path, '/topics.json'].each do |request_url|
	    	['deflate','gzip'].each do |compression_method|
	    		get request_url, {}, { HTTP_ACCEPT_ENCODING: compression_method }
	    		expect(response.headers['Content-Encoding']).to eq(compression_method)
	    	end
    	end
    end

    it "does not compress if compression not requested / supported" do
    	[root_path, '/topics.json'].each do |request_url|
	    	get request_url
	    	expect(response.headers['Content-Encoding']).to be_nil
    	end
    end
  end
end
