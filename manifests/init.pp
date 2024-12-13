# @summary
#   download and install github artifact
class githubartifact (
  Optional[Hash] $install = undef,
  Boolean $debug = false,
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
      content => template("${module_name}/downloadGithubArtifact.sh.erb"),
      mode => "0755",
    ;
  }
  if $install {
    ensure_resources("githubartifact::install", $install)
  }
}
