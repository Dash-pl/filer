# Contributing

Thank you for contributing to `nim_program`.

## Development setup

This project uses [Jujutsu](https://docs.jj-vcs.dev/) (`jj`) alongside Git. Use Jujutsu for development in this repository; direct Git operations may interfere with the expected repository state. Use Git only when working in a fork.

For an existing checkout, initialize Jujutsu as a colocated repository before making changes:

```sh
jj git init --colocate
```

Alternatively, clone the project with Jujutsu:

```sh
jj git clone <project-source>
```

## Building the bin

```sh
nimble build
```

## Submitting changes

- Keep changes focused and consistent with the existing Nim code style.
- Add or update tests in `tests/` when changing behavior.
- Run the relevant tests before submitting your changes.
- Describe what changed and why in your change description.

Create a change based on `stable` before submitting it:

```sh
jj new stable
```
after changing the files run:

```sh
jj bookmark set stable
jj git push -b stable
```

### Updating `beta`

To prepare a change that combines `stable` and `beta`, create the change with both revisions as parents:

```sh
jj new stable beta
```
after changing the files run to move the `beta` bookmark to it:

```sh
jj bookmark set beta
jj git push -b beta
```