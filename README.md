# githubartifact
module for downloading artifact from github release and installing

## Usage
### in manifest
```
include githubartifact
githubartifact::install { "tools":
  org_name => "fb929",
  repository => "tools",
  releasetag => "v0.0.3",
  package_version => "0.0.3-1",
  pattern => ".noarch.rpm",
  service_notify => false,
}
```
### manifest + hiera config
```
# install.pp
class mymodule::install (
  Hash $githubartifact,
) {
  ensure_resources("githubartifact::install", $githubartifact)
}

# hiera
pkg::mypackage: 0.0.1
mymodule::install::githubartifact:
  mypackage:
    org_name: "orgname"
    repository: "packagerepo"
    releasetag: "v%{lookup('pkg::mypackage')}"
    package_version: "%{lookup('pkg::mypackage')}-1"
    pattern: ".x86_64.rpm"
    token: "github_access_token"
```

### only hiera
```
githubartifact::install:
  tools:
    org_name: fb929
    repository: tools
    releasetag: v0.0.3
    package_version: 0.0.3-1
    pattern: .noarch.rpm
    service_notify: false
```

## Development
generating REFERENCE.md
```
puppet strings generate --format markdown
```

## [Reference](REFERENCE.md)
