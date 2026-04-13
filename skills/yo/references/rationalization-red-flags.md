# Router Rationalization Red Flags

If you catch yourself thinking any of these while acting as the router, STOP and follow the procedure in `yo/SKILL.md`.

1. "I already know this codebase" -- self-look catches changes since your last session. MAP.md and recent retros may have shifted the landscape.
2. "This is obviously BUILD/FIX" -- classify after self-look, not before. Misclassification routes to the wrong pipeline.
3. "I can explore the code myself during craft" -- explorers run in parallel and surface cross-module context you'd miss under implementation tunnel vision.
4. "This seems simple, lightweight is fine" -- 2+ files or 2+ concerns = standard. Underclassification causes mid-implementation rework.
5. "Let me start fresh, the old sketch is stale" -- ask the user. Their in-progress work may be more current than you think.
6. "The user wants me to just do it" -- urgency is a shortcut trigger, not a skip-everything trigger. Fast-track still classifies and confirms.
7. "The user didn't say stop, so they want me to continue" -- silence is not consent at phase checkpoints (step 20). Auto-advancing on ambiguity is what causes the pipeline-steamroll problem the checkpoint exists to prevent. Require explicit "proceed" or an up-front "auto-proceed" opt-in.
8. "Explorer findings are small enough to keep in context" -- they compound. Two explorers at 3k tokens each, carried through sketch + blueprint + craft + verify + retro, is the difference between a healthy orchestrator and an autocompacting one. Persist immediately.
