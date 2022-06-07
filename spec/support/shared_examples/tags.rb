shared_examples 'an object tagged in the context of' do |tag_context, options = {}|
  context tag_context do
    context_method = "#{tag_context}_list".to_sym
    plural = tag_context.pluralize

    it "accepts a comma-delimited string and turns it into an array of #{plural}" do
      notice = create(:dmca, context_method => 'foo, bar, baz, blee')

      expect(notice.send(context_method)).to eq ['foo','bar','baz','blee']
    end

    if options.has_key?(:case_insensitive)
      it "has lowercased #{plural} automatically" do
        notice = create(:dmca, context_method => 'FOO')

        expect(notice.send(context_method)).to eq ['foo']
      end
    else
      it "does not lowercase #{plural}" do
        notice = create(:dmca, context_method => 'FOO')

        expect(notice.send(context_method)).to eq ['FOO']
      end
    end
  end
end
