# nestd

This is the repo of `nestd` (**n**ot **e**xactly **std**, **n**im's **e**xtended **std**, **не** **std**) package. It contains various useful addons and tweaks to Nim's standard library.

The package itself is dependency-free, though using it alongside with other packages may enhance its possibilities.

## Why aren't all these things in `std`?

The reasons vary:
- some things are already merged in Nim's repo, but don't exist in any stable release, so a backport is needed
- some things provide workarounds for known issues
- some things are added to enhance different Nimble packages, thus will not be present in `std` anyway
- some things are added because they are considered simple enough and common enough to be used in various projects

## What can be added into `nestd`?

- backports of features from later versions of Nim
- workarounds for known issues
- various features which are simple enough to implement and can be useful in a wide range of libraries and applications

Please also note that this library tends to be dependency free. You must not include any other package as a dependency.

## License

This project is licensed under MIT License. see [LICENSE](LICENSE) for more details.

## Why is the main branch named `m`?

The main branch is the most used one, so it's a good idea to give it the shortest possible name. Also, `m` is a quite neutral name and is not connected to any controversies.
