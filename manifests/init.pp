# @summary
#   download and install github artifact
class githubartifact (
  Optional[Hash] $install = undef,
) {
  ensure_resources(package, { "jq" => { 'ensure' => 'present' }})
  file {
    [
      "/opt/",
      "/opt/githubartifact/",
      "/opt/githubartifact/bin/",
      "/opt/githubartifact/lib/",
    ]:
      ensure => directory,
    ;
    "/opt/githubartifact/bin/downloadGithubArtifact.sh":
      source => "puppet:///modules/${module_name}/downloadGithubArtifact.sh",
      mode => "0755",
    ;
  }
  if $install {
    ensure_resources("githubartifact::install", $install)
  }
}
