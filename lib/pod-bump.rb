require 'pod-bump/version'
require 'pod-bump/version_model'
require 'pod-bump/version_update_type'
require 'git'
require 'digest/sha1'

module PodBump

  VERSION_REGEX = %r{
    (0|[1-9]\d*)
    \.(0|[1-9]\d*)
    \.(0|[1-9]\d*)
    (?:\.(0|[1-9]\d*))? # is not valid sem versioning pattern to support 1.2.3.4
    (?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?
    (?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?
  }x

  def PodBump.pull_git_repo()
    work_dir = "./"
    git_current = Git.open(work_dir)
    git_current.pull()
    return true
  end

  def PodBump.commit_git_repo(path_to_podspec, commit_message, version_to_commit)
    result = false
    work_dir = "./"

    git_current = Git.open(work_dir)
    git_current.add(path_to_podspec)
    result_commit_message = commit_message == nil ? "Bumped Version " + version_to_commit : commit_message
    git_current.commit(result_commit_message)
    puts "Commit: " + result_commit_message
    git_current.add_tag(version_to_commit)
    puts "Tag: " + version_to_commit
    git_current.push("origin", git_current.current_branch, :tags=>true)
    puts "Pushed to remote " + "origin " + git_current.current_branch

    result = true
    return result
  end

  def PodBump.push_to_podspec(podspec_name, specs_repository)
    result = false

    if specs_repository != nil
      specs_repository_name = Digest::SHA1.hexdigest(specs_repository)
      puts "Specs repository name based on hash " + specs_repository_name

      repository_exits = system("pod repo list | grep " + specs_repository_name)

      puts "Repository already exists " + (repository_exits ? "YES" : "NO")

      if repository_exits == false
        command = "pod repo add " + specs_repository_name + " " + specs_repository
        puts "Running " + command
        result_of_repo_add = system(command)

        if result_of_repo_add == false
          puts "Could not add specs repository " + specs_repository
          return result
        end
      end

      command = "pod repo push " + specs_repository_name + " " + podspec_name
      puts "Running " + command
      result = system(command)
    else
      command = "pod trunk push " + podspec_name
      puts "Running " + command
      result = system("pod trunk push " + podspec_name)
    end

    if result == false
      puts "Could not update podspec please do it manually after fixing errors"
    end

    return result
  end

  def PodBump.string_with_count(count, character)
    result = ""
    count.times do |count|
      result += character
    end
    return result
  end

  def PodBump.get_version_from_podpsec(podspec_path)
    content = File.read(podspec_path)
    version_line_part = content.match(/\.version\s*=\s*["']#{VERSION_REGEX}["']/).to_s
    version = version_line_part.split(' ').last.tr('\'', '')

    return version
  end

  def PodBump.update_version_in_podspec(podpsec_path, version_string_to_update)
    lines = File.readlines(podpsec_path)
    output_lines = []
    version_pattern = ".version ="
    updated = false

    for line in lines
      prefix_count_of_spaces = line.size - line.lstrip.size
      version_line_part = line.match(/\.version\s*=\s*["']#{VERSION_REGEX}["']/).to_s

      if version_line_part.empty? == false
        items = line.split(' ')
        previous_version_string = items[2]
        version_to_update = "'" + version_string_to_update + "'"
        updated_line = line.gsub(previous_version_string, version_to_update)
        output_lines.push(updated_line)
        updated = true
      else
        output_lines.push(line)
      end
    end

    if updated == true
      output_file = File.open(podpsec_path, "w")
      for line in output_lines
        output_file.puts line
      end
      output_file.close()
    end

    return updated
  end

  def PodBump.find_podspec_in_current_folder
    return Dir["./*.podspec"].first
  end

  def PodBump.find_podspec_name_in_current_folder
    file = Dir["*.podspec"].first
    return file
  end

  def PodBump.get_version_string_to_update(bump_type, options, version_string)
    version = VersionModel.new(version_string)
    version_to_update = nil

    if bump_type == VersionUpdateType::MAJOR
      version.increase_major()
      version_to_update = version.to_string_version
    elsif bump_type == VersionUpdateType::MINOR
      version.increase_minor()
      version_to_update = version.to_string_version
    elsif bump_type == VersionUpdateType::PATCH
      version.increase_patch()
      version_to_update = version.to_string_version
    elsif bump_type == VersionUpdateType::CURRENT
      version_to_update = version_string
    elsif options[:version] != nil
      version_to_update = options[:version]
    end

    return version_to_update
  end

  def PodBump.run(arguments, options)
    if options[:print_version] == true
      puts "pod-bump version " + PodBump::VERSION
      return
    end

    if arguments.size > 2 || (arguments.size == 2 && options[:version] == nil)
      puts "Invalid parameters. Please check documentation"
      return
    end

    bump_type = arguments.first

    if options[:version] != nil && options[:version].match(VERSION_REGEX).to_s.empty?
      puts "Version to set should use valid semantic versioning"
      return
    end

    podspec_file_path = find_podspec_in_current_folder
    if podspec_file_path == nil
      puts "No podspec file found in current directory"
      return
    end

    if options[:no_commit] == nil
      pull_git_repo()
      puts "Pulled git repository"
    end

    version = get_version_from_podpsec(podspec_file_path)
    if version == nil
      puts "Could not find version line in podspec " + podspec_file_path
      return
    end

    version_to_update = get_version_string_to_update(bump_type, options, version)
    if version_to_update == nil
      puts "Invalid version to update passed to parameters. Please check documentation."
      return
    end

    updated_podspec = update_version_in_podspec(podspec_file_path, version_to_update)
    if updated_podspec == false
      puts "Could not update version in podspec " + podspec_file_path
      return
    end

    puts "Updated version in podspec " + podspec_file_path

    if options[:no_commit] == true
      return
    end

    commit_git_repo = commit_git_repo(podspec_file_path, options[:commit_message], version_to_update)
    if commit_git_repo == false
      puts "Could not commit to git repo"
      return
    end

    if options[:no_push] == true
      puts "Successfully bumped version to " + version_to_update
      return
    end

    podspec_name = find_podspec_name_in_current_folder()
    puts "PODSPEC NAME " + podspec_name
    pushed_to_podspec = push_to_podspec(podspec_name, options[:spec_repository])

    if pushed_to_podspec == false
      puts "Could not push to podspec repository"
      return
    end

    puts "Successfully bumped version to " + version_to_update
  end
end