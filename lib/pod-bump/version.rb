module PodBump
    
    class Version

        def initialize(version_string)
          versions = version_string.split(".")
          @major = versions[0].to_i
          @minor = versions[1].to_i
          @patch = versions[2].to_i
        end
      
        def major
          return @major
        end
      
        def minor
          return @minor
        end
      
        def patch
          return @patch
        end
        
        def increase_major
          @major += 1
        end
      
        def increase_minor
          @minor += 1
        end
      
        def increase_patch
          @patch += 1
        end
      
        def to_string_version
          @major.to_s + "." + @minor.to_s + "." + @patch.to_s
        end
    end
end