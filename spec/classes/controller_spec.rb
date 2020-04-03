require 'spec_helper'

describe 'bolt::controller' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { {  'user'                    => 'bolt',
                        'puppetdb_url'            => 'https://puppet.example.org:8081',
                        'inventory_template_path' => '/home/bolt/inventory-template.yaml', } }

      it { is_expected.to compile }
    end
  end
end
