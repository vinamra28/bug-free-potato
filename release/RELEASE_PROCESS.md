## Release Process

## Table of Content

- [Summary](#summary)
- [Motivation](#motivation)
- [Current Scenario](#current-scenario)
- [Proposal](#proposal)
- [Alternatives](#alternatives)
  - [Use dates as versioning](#use-dates-for-versioning)
- [Questions](#questions)

## Summary

This document mainly focuses on the release process that should be followed by each
repository that comes under issuer tokenization project.

## Motivation

Applications evolve over time based on product requirements. A new version of the
application is published in the following cases:

- Required set of features(including bug fixes) are ready to be shipped
- A bug was identified in one of the previous releases that requires an immediate
  patch release which doesn't contain any features
- A functionality is to be added which is backward compatible and is required at priority

## Current Scenario

- Our team current cuts the release from github UI for instant process
- No proper versioning is followed
- Banks have different requirements for the same application

## Proposal

The proposed solution is to follow [Semver][semver] versioning with incremental numbers
and all major releases should start from v1.x.x and so on. All development releases
should follow v0.x.x.

- With each major release, a release branch should be cut which should be like
  `release-v<major-version>.x.x`
- Any fix that needs to go in one of the previous releases:
  - Fix should go first in master bracnh
  - The same fix should be cherry-picked in the release branch of the corresponding release
  - A release should be made from that release branch

### Advantages

- Easy to track the minor and patch release for a major release

### Disadvantages

- Difficult to decide when to cut a minor or a patch release

## Alternatives

### Use dates for versioning

We can tag the releases uniquely using the following pattern: `v<nth release>.<month>.<year>`.
Example: We want to cut a release in the month of 11/2022 and this will be the first release
of that particular month so the tag would look like `v1.11.2022` and this will go on like
`v2.11.2022`, `v1.12.2022` and so on.

#### Advantages

- We can easily identify the no of releases that we had cut during a particular month
- Ease in versioning the releases

#### Disadvantages

- It will be difficult to differentiate between major, minor and patch releases
- Making a minor or patch release for a particular major release will be difficult

[semver]: https://semver.org/

## Questions

- Some repositories are maintaining separate branches for separate banks
  so it becomes difficult to track the versioning for each bank so how should
  the release be cut in the scenario?

  - Solution 1: Merge the branches into the master branch and add a configuration
    for bank in order to enable their respective features
  - Solution 2: Append the bank name when cutting the release. Example: `equitas-v1.0.0`

- What should be the cadence?
- Should we have release managers along with rotations?
