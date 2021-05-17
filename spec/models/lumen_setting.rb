require 'rails_helper'

describe LumenSetting, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :key }
    it { is_expected.to validate_presence_of :value }
  end

  context '.get' do
    it "gets a Lumen module constant when it's set" do
      Lumen.const_set('WOW_SO_CONST', 'wow_so_value')

      expect(LumenSetting.get('wow_so_const')).to eq 'wow_so_value'
    end

    it "returns nil for a Lumen module constant when it's not set" do
      expect(LumenSetting.get('wow_not_so_const')).to eq nil
    end

    it 'returns nil when the key attribute is nil' do
      expect(LumenSetting.get(nil)).to eq nil
    end

    it 'finds a lumen setting record' do
      LumenSetting.create!(
        name: 'Wo so setting nice',
        key: 'wow_so_setting_record',
        value: '777'
      )

      Lumen.const_set('SETTINGS', LumenSetting.all)

      expect(LumenSetting.get_i('wow_so_setting_record')).to eq 777
    end
  end

  context '.get_i' do
    it 'converts a const value to integer' do
      Lumen.const_set('WOW_SO_CONST', '0')

      expect(LumenSetting.get('wow_so_const')).to eq '0'
      expect(LumenSetting.get_i('wow_so_const')).to eq 0
    end
  end
end
