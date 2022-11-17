## Release Process

This document mainly focuses on the release process which we can try to adopt.

## Current Scenario

- Our team current cuts the release from github UI for instant process
- No proper versioning is followed
- No major release has been cut as of now for any of the applications
  - If we cut the release as well then no such differentiation
- Banks have different requirements for the same application

## Minor/Patch Release

In order to cut a minor release

- Create a pull request with master as base branch
- Once PR is merged, create a PR with base branch as the release branch whose minor version
  you want to release. Example:

  ```
  App Version: v1.0.0
  Release Branch: release-v1.0.0
  ```

  - Run `git checkout release-v1.0.0`
  - `git cherry-pick <commit hash>`
  - Create a new pull request with the changes you want to push into the release branch
  - Once PR is merged, run the script to create the patch release. Here in this case
    it would be v1.0.1
