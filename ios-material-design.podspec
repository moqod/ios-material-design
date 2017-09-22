
Pod::Spec.new do |s|
  s.name         = "ios-material-design"
  s.version      = "0.0.1-quizlet"
  s.summary      = "iOS Material Design Library"
  s.description  = "Inspired by Material Design guideline from Google."

  s.homepage     = "https://github.com/moqod/ios-material-design"
  s.license      = "MIT"
  s.author       = "Moqod"
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/quizlet/ios-material-design.git", :tag => s.version }
  s.source_files  = "Classes", "MaterialDesign/MaterialDesign/**/*.{h,m}"
end
