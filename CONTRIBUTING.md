# Contributing

I value any contribution to Hoe::Halostatue you can provide: a bug report, a
feature request, or code contributions. There are a few guidelines for
contributing to Hoe::Halostatue:

- Match my coding style.
- Use a thoughtfully-named topic branch that contains your change. Rebase your
  commits into logical chunks as necessary.
- Use [quality commit messages][quality commit messages].
- Do not change the version number; when your patch is accepted and a release is
  made, the version will be updated at that point.
- Submit a GitHub pull request with your changes.
- New or changed behaviours require appropriate documentation.

Hoe::Halostatue uses Ryan Davis's [Hoe][Hoe] to manage the release process, and
it adds a number of rake tasks.

## Workflow

Here's the most direct way to get your work merged into the project:

- Fork the project.
- Clone your fork (`git clone git://github.com/<username>/hoe-halostatue.git`).
- Create a topic branch to contain your change
  (`git checkout -b my_awesome_feature`).
- Hack away, add tests. Not necessarily in that order.
- Make sure everything still passes by running `rake`.
- If necessary, rebase your commits into logical chunks, without errors.
- Push the branch up (`git push origin my_awesome_feature`).
- Create a pull request against halostatue/hoe-halostatue and describe what your
  change does and the why you think it should be merged.

[quality commit messages]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[hoe]: https://github.com/seattlerb/hoe
