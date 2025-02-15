# kotlin-toolchain.nvim

This plugin contains a set of different useful extensions
to work with Kotlin code in a world where there is no
stable LSP available for Kotlin.

In general, I only use LSPs for navigation in the code.
I don't need autocompletion features, I do read
documentation before using any library, so I only
need a subset of the LSP features that may be implemented
without an actual LSP.

> [!WARNING]
> This plugin is made for fun. I only implement featues
> that need for my Kotlin development. PRs are very welcome.
> I want this to be a collaborative development and I will
> review and help with PRs in any way you need it. Just don't
> think that I will implement something **you** need in my free time.

## Supported Features

### Format File

Command that will accumulate all the formatting commands, so you can
plug this command in in something like conform.

```lua
require("kotlin-toolchain").file.format({
  sort_imports = true
})
```

### Sort Imports

Sort imports in current file:

```lua
require("kotlin-toolchain").file.sort_imports()
```

## TODOs

(Just some ideas would be fun to have, not something
I will 100% manage to implement)

- [ ] Find import
  - [ ] Find in local codebase
  - [ ] Find in libraries (I believe we can analyze gradle build results)
- [ ] Goto definition
  - [ ] Grep in local codebase
  - [ ] Grep in sources
- [ ] Gradle Continuous Mode Integration
  For development I use `./gradlew [module]:classes -t`
  which helps me to get all the errors really fast.
  It might be useful to create quickfix list and parse
  all the errors from gradle.
  This might be implemented as a separate LSP that is
  backed by a gradle daemon and hence it would be useful
  for our VSCode fellows.

## Installation

Copy and paste this to your favouritve package installer:

```lua
'y9san9/kotlin-toolchain.nvim'
```

## Contact

Feel free to contact me for any questions including
chat chatting for fun. Checkout my GitHub profile
for more info.

