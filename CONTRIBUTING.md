# Contributing to slackin-swift

First off - thank you!!!

## The Goal

As of this writing, [slackin](https://github.com/rauchg/slackin) is the goal to aim for. By aiming for this, we hope to prove that Swift is as viable as Node.js for web applications.

Once software parity has been reached, a manifesto can be designed to discuss future ideas, but this should always remain simple to use, just like the original :smile:

## Branching

Please fork slackin-swift and submit a pull request to make any contributions. Repeated contributors who would like to maintain any branches that exist should email me about becoming a full-time collaborator [here](mailto:david@okun.io)

## Pull Requests

Please submit any feature requests or bug fixes as a pull request.

Please make sure that all pull requests have the following:

- a descriptive title
- a meaningful body of text to explain what the PR does
- if it fixes a pre-existing issue, include the issue number in the body of text

Pushing directly to master is disallowed.

## Running locally

To run Lumina locally, please follow these steps:

- Clone the repository
- Run `swift build`
- Run `.build/debug/slackin-swift **insert token here**` --OR-- `./runDocker **insert token here**`

To develop on slackin-swift:

- Run `swift package generate-xcodeproj`

**Thanks for contributing! :100:**