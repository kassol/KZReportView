Pod::Spec.new do |s|
  s.name         = "KZReportView"
  s.version      = "1.0.0"
  s.summary      = "A view to show report data."
  s.homepage     = "https://github.com/kassol/KZReportView"
  s.license      = "MIT"
  s.author       = { "kassol" => "kassol.zx@gmail.com" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/kassol/KZReportView.git", :tag => s.version.to_s }
  s.source_files  = "KZReportView/KZReportView.{h,m}", "KZReportView/KZReportCell.{h,m}"
end
