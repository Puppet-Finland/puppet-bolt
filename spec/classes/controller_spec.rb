require 'spec_helper'

describe 'bolt::controller' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'id'                            => 'default',
          'user'                          => 'bolt',
          'use_puppet_certs_for_puppetdb' => true,
        }
      end

      it { is_expected.to compile }
    end
  end
end
