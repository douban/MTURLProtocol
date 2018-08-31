
Pod::Spec.new do |s|
  s.name             = 'MTURLProtocol'
  s.version          = '0.1.1'
  s.summary          = 'Multiple NSURLProtocol alternative solution.'
  s.description      = <<-DESC
MTURLProtocol is a subclass of NSURLProtocl and itself is subclass restricted. It is used to avoid implementing multiple NSURLProtocol subclasses in one application.
                       DESC

  s.homepage         = 'https://github.com/douban/MTURLprotocol'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huangduyu' => 'duyu1010@gmail.com' }
  s.source           = { :git => 'https://github.com/douban/MTURLprotocol.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'MTURLProtocol/Classes/**/*'
end
