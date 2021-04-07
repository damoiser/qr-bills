require 'rake'

Gem::Specification.new do |s|
  s.name        = "qr-bills"
  s.version     = "0.3"
  s.date        = "2021-04-07"
  s.summary     = "QR-bills support for swiss payments"
  s.description = "QR-bills support for swiss payments, for full documentation please refer to github repo: https://github.com/damoiser/qr-bills"
  s.authors     = ["Damiano Radice"]
  s.email       = "dam.radice@gmail.com"
  s.files       = FileList["lib/**/*",
                  "web/assets/**/*",
                  "config/locales/*.yml"]
  s.homepage    = "https://github.com/damoiser/qr-bills"
  s.license     = "MIT"
  s.metadata    = {
    "bug_tracker_uri"   => "https://github.com/damoiser/qr-bills/issues",
    "changelog_uri"     => "https://github.com/damoiser/qr-bills/CHANGELOG.md",
    "documentation_uri" => "https://github.com/damoiser/qr-bills/README.md",
    "homepage_uri"      => "https://github.com/damoiser/qr-bills",
    "source_code_uri"   => "https://github.com/damoiser/qr-bills",
    "wiki_uri"          => "https://github.com/damoiser/qr-bills"
  }
  s.required_ruby_version = ">= 2.7.1"
  s.add_runtime_dependency("i18n", ">= 1.8.3", "< 2")
  s.add_runtime_dependency("rqrcode", ">= 1.1.2", "< 2")
  s.add_development_dependency("rspec", "~> 3.9")
  s.add_development_dependency("rake", "~> 13.0")
end