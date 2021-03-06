require_relative 'lib/pod-bump/version'

Gem::Specification.new do |s|
    s.name        = 'pod-bump'
    s.version     = PodBump::VERSION
    s.summary     = "Pod Bump"
    s.description = "Pod Bump is command line tool that should be used to bump your podspec version"
    s.authors     = ["Maksim Kita"]
    s.email       = 'kitaetoya@gmail.com'
    s.homepage = 'https://github.com/kitaisreal/pod-bump'
    s.files       = [
        "lib/pod-bump.rb",
        "lib/pod-bump/version.rb",
        "lib/pod-bump/version_model.rb",
        "lib/pod-bump/version_update_type.rb"]
    s.license     = 'MIT'
    s.executables << 'pod-bump'
    s.add_runtime_dependency "git", '1.6.0'
  end