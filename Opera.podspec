Pod::Spec.new do |s|
  s.name             = 'Opera'
  s.version          = '0.1.0'
  s.summary          = 'Factory pattern for ObjC'

  s.description      = 'A generic implementation of factory pattern for ObjC'

  s.homepage         = 'https://github.com/CopyIsRight/Opera'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Pietro Caselani" => "pc1992@gmail.com", "Felipe Lobo" => "frlwolf@gmail.com" }
  s.source           = { :git => 'https://github.com/CopyIsRight/Opera.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'Opera/Classes/**/*'
end