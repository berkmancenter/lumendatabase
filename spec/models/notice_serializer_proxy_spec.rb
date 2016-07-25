require 'spec_helper'

describe NoticeSerializerProxy, type: :model do

  it "uses the instance's serializer when present" do
    trademark = build_stubbed(:trademark)
    serialized = TrademarkSerializer.new(trademark)
    allow(serialized).to receive(:a_method).and_return(:a_value) # test delegation
    expect(TrademarkSerializer).to receive(:new).with(trademark).and_return(serialized)

    delegator = NoticeSerializerProxy.new(trademark)

    expect(delegator.a_method).to eq :a_value
  end

  it "uses NoticeSerializer when no custom serializer is present" do
    object = double('Instance', active_model_serializer: nil)
    serialized = NoticeSerializer.new(object)
    allow(serialized).to receive(:a_method).and_return(:a_value) # test delegation
    expect(NoticeSerializer).to receive(:new).with(object).and_return(serialized)

    delegator = NoticeSerializerProxy.new(object)

    expect(delegator.a_method).to eq :a_value
  end

end
