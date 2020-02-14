# Pod Bump

A gem to bump versions of cocoa pods podspec.

 - bumps version major / minor / patch
 - commit changes
 - added tag
 - push to specs repository
 
# Installation
 
```
gem install pod-bump
```

# Usage

### Bump (major, minor, patch)

```
pod-bump major # Bump version 0.0.0 to 1.0.0
```

```
pod-bump minor # Bump version 0.0.0 to 0.1.0
```

```
pod-bump patch # Bump version 0.0.0 to 0.0.1
```

### Set (version)

```
pod-bump set 1.2.3 # Set version to 1.2.3  
```

Note: Version should pass semantic validation. See https://semver.org/

## Options

### `-s [REPO_URL], --specs-repository [REPO_URL]`

```
pod-bump major -s https://github.com/CocoaPods/Specs
```

```
pod-bump major --specs-repository https://github.com/CocoaPods/Specs
```

Specs repository to push. Default is 'trunk'. See https://guides.cocoapods.org/making/private-cocoapods.html

### `--commit-message [MSG], -m [MSG]`

Change commit message. Default 'Bumped Version [Vesion]'

```
pod-bump patch --message "Additional info"
```

```
pod-bump patch --m "Additional info"
```

### `--no-commit`

Do not commit and push to podspec after podspec version bump.

```
pob-bump major --no-commit
```

### `--version`

Prints current pod-bump version

```
pod-bump --version
```