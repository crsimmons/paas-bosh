require 'spec_helper'

describe Bosh::Deployer::Config do
  before { @dir = Dir.mktmpdir('bdc_spec') }
  after { FileUtils.remove_entry_secure @dir }

  it 'should default agent properties' do
    config = Psych.load_file(spec_asset('test-bootstrap-config.yml'))
    config['dir'] = @dir
    Bosh::Deployer::Config.configure(config)

    properties = Bosh::Deployer::Config.cloud_options['properties']
    expect(properties['agent']).to be_kind_of(Hash)
    expect(properties['agent']['mbus'].start_with?('https://')).to be(true)
    expect(properties['agent']['blobstore']).to be_kind_of(Hash)
  end

  it 'should map network properties' do
    config = Psych.load_file(spec_asset('test-bootstrap-config.yml'))
    config['dir'] = @dir
    Bosh::Deployer::Config.configure(config)

    networks = Bosh::Deployer::Config.networks
    expect(networks).to be_kind_of(Hash)

    net = networks['bosh']
    expect(net).to be_kind_of(Hash)
    %w(cloud_properties netmask gateway ip dns default).each do |key|
      expect(net[key]).not_to be_nil
    end
  end

  it 'should default vm env properties' do
    env = Bosh::Deployer::Config.env
    expect(env).to be_kind_of(Hash)
    expect(env).to have_key('bosh')
    expect(env['bosh']).to be_kind_of(Hash)
    expect(env['bosh']['password']).to be_nil
  end

  it 'should contain default vm resource properties' do
    Bosh::Deployer::Config.configure('dir' => @dir, 'cloud' => { 'plugin' => 'vsphere' })
    resources = Bosh::Deployer::Config.resources
    expect(resources).to be_kind_of(Hash)

    expect(resources['persistent_disk']).to be_kind_of(Integer)

    cloud_properties = resources['cloud_properties']
    expect(cloud_properties).to be_kind_of(Hash)

    %w(ram disk cpu).each do |key|
      expect(cloud_properties[key]).not_to be_nil
      expect(cloud_properties[key]).to be > 0
    end
  end
end
