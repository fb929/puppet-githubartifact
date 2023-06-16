# @example install rpm
#   githubartifact::install { "tools":
#     org_name => "fb929",
#     repository => "tools",
#     releasetag => "v0.0.3",
#     package_version => "0.0.3-1",
#     pattern => ".noarch.rpm",
#     service_notify => false,
#   }
#
# @param org_name
#   required, name of the organization on github
# @param repository
#   required, name of the repository on github
# @param releasetag
#   required, tag for release
# @param pattern
#   required, pattern for find asset
define githubartifact::install (
  String $org_name,
  String $repository,
  String $releasetag,
  String $pattern,
  Variant[String,Boolean] $token = false,
  Optional[String] $dest_dir = undef,
  Optional[String] $asset_name = undef,
  Optional[Boolean] $debug = false,
  Optional[Boolean] $install = true,
  Optional[String] $package_name = undef,
  Optional[String] $package_version = undef,
  Optional[Boolean] $service_notify = true,
  Optional[String] $service_name = undef,
  Optional[Any] $notify = undef,
) {
  if $dest_dir== undef {
    $_dest_dir = "/opt/githubartifact/lib"
  } else {
    $_dest_dir = $dest_dir
  }
  if $asset_name == undef {
    $_asset_name = "${name}-${releasetag}$pattern"
  } else {
    $_asset_name = $asset_name
  }
  if $package_name == undef {
    $_package_name = $name
  } else {
    $_package_name = $package_name
  }
  if $package_version == undef {
    $_package_version = regsubst($releasetag,'^v(.*)$','\\1')
  } else {
    $_package_version = $package_version
  }
  if $service_name == undef {
    $_service_name = $name
  } else {
    $_service_name = $service_name
  }
  if $notify == undef {
    if $service_notify {
      $_notify = Service[$_service_name]
    } else {
      $_notify = []
    }
  } else {
    $_notify = $notify
  }
  exec { "download $name":
    command => "/opt/githubartifact/bin/downloadGithubArtifact.sh",
    environment => [
      "ORG_NAME=$org_name",
      "REPOSITORY=$repository",
      "RELEASETAG=$releasetag",
      "PATTERN=$pattern",
      "TOKEN=$token",
      "DEST_DIR=$_dest_dir",
      "ASSET_NAME=$_asset_name",
      "DEBUG=$debug",
    ],
    creates => "$_dest_dir/$_asset_name",
    require => File["/opt/githubartifact/bin/downloadGithubArtifact.sh"],
  }
  package { $_package_name:
    ensure => $_package_version,
    source => "$_dest_dir/$_asset_name",
    require => Exec["download $name"],
    notify => $_notify,
  }
}
