## When to use this Script

- This script is majorly used for cutting a stable release and doing a code freeze.
- This script is not intended to be used for cutting development releases
- Development release should follow the pattern `v0.[0-9]*\.[0-9]+`

## How to Draft a release

1. Make sure:

   1. you have git and gh CLI installed

      - If gh CLI is not installed then please install it by referring https://cli.github.com/manual/installation
      - Run `gh auth login` and follow the steps
      - Make sure that you authorize github CLI to perform actions on repositories present inside razorpay org

   1. you don't have any local changes, if any, please stash them or commit them

1. Run the script: `./release/release.sh`

   - Enter the version for your new release, eg, `v1.2.0`
   - Enter the last tag version with which you made the release, eg, `v1.0.0`
   - Enter the bank name for which you want to cut the release. (_Accepted values: kvb, equitas, canara, axis_)
   - Enter the base branch from which you want to cut the release. Leave it blank if in case you want to cut
     the release from default base branch ie master/main

**Note**: It is the duty of the PR reviewer to make sure that [changelog.md](./release/changelog.md) is always
updated with necessary changelog

## Rules for Changelog

1. Whenever a PR is made towards the repository, author should update the changelog file
1. It should be the duty of PR reviewer to detect if there are any changes which requires changelog updation
1. Each entry in changelog should carry a valid JIRA link

## Post release is made

1. Script that was run previously will clear the [changelog.md](./release/changelog.md) and replace that with placeholder
   text, commit it and create a PR for the same
