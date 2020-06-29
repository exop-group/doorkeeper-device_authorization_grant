# frozen_string_literal: true

require 'test_helper'
require 'generators/doorkeeper/device_authorization_grant/install_generator'

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Doorkeeper::DeviceAuthorizationGrant::InstallGenerator
  destination Rails.root.join('tmp', 'generators')

  setup do
    prepare_destination

    FileUtils.mkdir(::File.join(destination_root, 'config'))
    FileUtils.copy_file(
      ::File.join(__dir__, 'templates', '/routes.rb'),
      Rails.root.join(destination_root, 'config', 'routes.rb')
    )

    run_generator
  end

  test 'it creates an initializer file' do
    assert_file 'config/initializers/doorkeeper_device_authorization_grant.rb'
  end

  test 'it adds sample route' do
    assert_file 'config/routes.rb', /use_doorkeeper_device_authorization_grant/
  end
end
