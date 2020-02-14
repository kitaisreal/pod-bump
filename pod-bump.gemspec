Gem::Specification.new do |s|
    s.name        = 'pod-bump'
    s.version     = '0.0.1'
    s.summary     = "Pod Bump"
    s.description = "Pod Bump is command line tool that should be used to bump your podspec version"
    s.authors     = ["Maksim Kita"]
    s.email       = 'kitaetoya@gmail.com'
    s.files       = [
        "lib/pod-bump.rb",
        "lib/pod-bump/version.rb",
        "lib/pod-bump/version_update_type.rb"]
    s.homepage    = 'https://rubygems.org/gems/pod-bump'
    s.license     = 'MIT'
    s.executables << 'pod-bump'
    s.add_runtime_dependency "git", '1.6.0'
  end