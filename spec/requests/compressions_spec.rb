require 'rails_helper'

RSpec.describe "Compressions", type: :request do
  describe Rack::Deflater do

    it "compresses response if requested" do
    	get root_path
    	uncompressed_response_length = response.headers['Content-Length']
    	['deflate','gzip'].each do|compression_method|
    		get root_path, {}, { HTTP_ACCEPT_ENCODING: compression_method }
    		expect(response.headers['Content-Encoding']).to eq(compression_method)
    		expect(response.headers['Content-Length']).to be <= uncompressed_response_length
    	end
    end

    it "does not compress if compression not requested / supported" do
    	get root_path
    	expect(response.headers['Content-Encoding']).to be_nil
    end
  end
end
