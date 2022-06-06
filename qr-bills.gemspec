Gem::Specification.new do |s|
  s.name        = "qr-bills"
  s.version     = "1.0.9"
  s.date        = "2022-05-01"
  s.summary     = "QR-bills support for swiss payments"
  s.description = "QR-bills support for swiss payments, for full documentation please refer to github repo: https://github.com/damoiser/qr-bills"
  s.authors     = ["Damiano Radice"]
  s.email       = "dam.radice@gmail.com"
  s.files       = Dir["lib/**/*"] + Dir["web/assets/**/*"] + Dir["config/locales/*.yml"]
  s.require_paths = ["lib"]
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
  s.required_ruby_version = ">= 2.7.4"
  s.add_runtime_dependency("i18n", ">= 1.8.3", "< 2")
  s.add_runtime_dependency("rqrcode", ">= 2.1", "< 3")
  s.add_runtime_dependency("prawn", ">= 1", "< 3")
  s.add_runtime_dependency("prawn-svg")

  s.add_development_dependency("rspec", "~> 3.9")
  s.add_development_dependency("rake", "~> 13.0")
  s.add_development_dependency("pry")
  s.add_development_dependency("byebug")
end
