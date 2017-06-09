# github-tag-autoincrement

This Docker image is targeting a very primal need: a CI-CD pipeline hook-able docker image, which will auto-increment patch version (Sematic Versioning) automatically with out any other libraries in your codebase. You can hook up this in your CI-CD chain so that this will be invoked for each commit to master. By doing so, you can convert cryptic and hard-to-remember commit SHAs to nice auto-incrementable semver tags, for example v0.0.1.

This Docker image is intended to use with your CI-CD pipeline (drone.io / travis). This intends to address these 2 issues
1) Including a library just to auto-increment your patch version and tag (Nebula release plugin or gradle git etc) in your codebase which has nothing to do with your business functionality.
2) Manually upgrading the version in your codebase or Manually drafting a release to your Dev branch when the above said libraries are not available in your choice of programming language.
