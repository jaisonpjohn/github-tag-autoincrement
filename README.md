[![Docker Build Status](https://img.shields.io/docker/build/jaisonpjohn/github-tag-autoincrement.svg)](https://hub.docker.com/r/jaisonpjohn/github-tag-autoincrement/)
[![Docker ImageLayers Size](https://img.shields.io/imagelayers/image-size/jaisonpjohn/github-tag-autoincrement/latest.svg)](https://hub.docker.com/r/jaisonpjohn/github-tag-autoincrement/)
[![Docker ImageLayers](https://img.shields.io/imagelayers/layers/jaisonpjohn/github-tag-autoincrement/latest.svg)](https://hub.docker.com/r/jaisonpjohn/github-tag-autoincrement/)
[![Docker Stars](https://img.shields.io/docker/stars/jaisonpjohn/github-tag-autoincrement.svg)](https://hub.docker.com/r/jaisonpjohn/github-tag-autoincrement/)
[![Docker pulls](https://img.shields.io/docker/pulls/jaisonpjohn/github-tag-autoincrement.svg)](https://hub.docker.com/r/jaisonpjohn/github-tag-autoincrement/)
# github-tag-autoincrement
This light-weight Docker image is targeting a very primal need: a CI-CD pipeline hook-able docker image, which will auto-increment patch version (Semantic Versioning) without any other libraries in your codebase (I am looking at you Nebula Release plugin - http://nebula-plugins.github.io/). For example, You can hook up this image in your CI-CD chain so that it will be invoked for each commit to master. By doing so, you can convert cryptic and hard-to-remember commit SHAs to nice auto-incrementable semver tags, for example v0.0.1.

This Docker image is intended to use with your CI-CD pipeline (drone.io / travis) and it addresses these 2 issues
1) Including a library just to auto-increment your patch version and tag (Nebula release plugin or gradle git etc) in your codebase which has nothing to do with your business functionality.
2) Manually upgrading the version of your codebase or Manually creating a Tag when the above-said libraries are not available in your choice of programming language.

# Usage

```
docker run \
     -e "GITHUB_REPO_URL=https://api.github.com/repos/so-random-dude/oneoffcodes" \
     -e "TAG_PREFIX=v" \
     -e "GITHUB_USERNAME=<YOURUSERNAME>" \
     -e "GITHUB_PASSWORD=<YOURPASSWORD>" \
     jaisonpjohn/github-tag-autoincrement
```     
If you just need to know the version in making so that you can tag your artifact with that version before you push to your Artifactory (Dockerhub / JFrog Artifactory / ECR / GCR etc), just add "MODE=READONLY"
```
docker run \
     -e "GITHUB_REPO_URL=https://api.github.com/repos/so-random-dude/oneoffcodes" \
     -e "TAG_PREFIX=v" \
     -e "GITHUB_USERNAME=<YOURUSERNAME>" \
     -e "GITHUB_PASSWORD=<YOURPASSWORD>" \
     -e "MODE=READONLY" \
     jaisonpjohn/github-tag-autoincrement
```
