#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'python_runtime_macos'
  s.version          = '0.0.1'
  s.summary          = 'A macOS implementation of the python_runtime plugin.'
  s.description      = <<-DESC
  A macOS implementation of the python_runtime plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx
  s.osx.deployment_target = '10.11'
  s.swift_version = '5.0'

  # Only include the micromamba binary in resources
  # s.resources = ['assets/micromamba']

  # Add a script phase to download micromamba
  # s.script_phase = {
  #   :name => 'Download Micromamba',
  #   :script => 'cd "${PODS_TARGET_SRCROOT}" && ./download_micromamba.sh',
  #   :execution_position => :before_compile
  # }
end

