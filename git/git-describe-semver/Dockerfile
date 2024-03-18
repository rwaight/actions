FROM scratch
LABEL "org.opencontainers.image.source" = "https://github.com/rwaight/actions"
LABEL "org.opencontainers.image.url" = "https://github.com/rwaight/actions/tree/main/git/git-describe-semver"
LABEL "org.opencontainers.image.description" = "Replacement for `git describe --tags` that produces [semver](https://semver.org/) compatible versions that follow to semver sorting rules."
LABEL "org.opencontainers.image.documentation" = "https://github.com/rwaight/actions/blob/main/git/git-describe-semver/README.md"
# this fails because 'github.event.release.tag_name' is not valid # LABEL "org.opencontainers.image.version" = "${{ github.event.release.tag_name }}"
ENTRYPOINT ["/bin/git-describe-semver"]
COPY git-describe-semver /bin/git-describe-semver
WORKDIR /workdir