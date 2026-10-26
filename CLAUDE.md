# NixOS guest spike

Disposable guest workload flake. Guest OS configuration and image outputs live here; Ashyn owns Incus instance existence/resources; dotfiles owns reusable modules.

Build before pushing. A push to master deploys through the guest's comin. Never activate the current machine or manually switch this guest alongside comin. Do not bake secrets or unique machine identities into the image.

Arcanum is the source of truth for decisions and changes. Read its CLAUDE.md, index.md, and current monthly log; record assisted changes there and update `wiki/Projects/Ashyn/Ashyn.md`. Keep no wiki or docs directory here.
