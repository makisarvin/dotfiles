# pi-dev Profiles

This repository contains predefined pi agent configuration profiles for use with the `project-configure` skill.

## Purpose

The `project-configure` skill allows users to quickly set up a local project with relevant pi packages, skills, and extensions by applying one or more predefined profiles. This repository is the default source of those profiles.

## Structure

```
pi-dev/
├── profiles.json          # Profile registry defining available configurations
├── AGENTS.md              # This file
│
├── coding/                # Core software development tools
│   └── .pi/
│       └── settings.json  # web access, code intelligence (pi-lens)
│
├── context/               # Interactive context & workflow tools
│   └── .pi/
│       └── settings.json  # ask-user-question, todo, pi-rlm
│
├── search/                # Search & content extraction capabilities
│   └── .pi/
│       └── extensions/    # search-tools.ts
│
├── common/                # Shared packages useful across all profiles
│   └── .pi/
│       └── settings.json  # pi-hypa, pi-observational-memory
│
└── languages/             # Language-specific composite profiles
    └── luau/
        └── profile.json   # Luau/Roblox configuration
```

## Profile Types

- **Single-source** (`sourceDir`): A simple profile copied from one folder (e.g., `coding`, `context`, `search`, `common`).
- **Composite** (`sourceDirs`): Merges multiple single-source profiles (e.g., `architecture` combines `coding + context + search`).
- **Language config** (`config`): Points to a JSON file inside `languages/<lang>/` that defines its own `sourceDirs` and extends base profiles with language-specific tooling.

## Adding a New Profile

1. Create a new directory with a `.pi/` subfolder containing `settings.json` (and optionally `skills/`, `extensions/`, `npm/`).
2. Add an entry to `profiles.json` with either `sourceDir`, `sourceDirs`, or `config`.
3. Profiles are applied using the `project-configure` skill or `configure.sh <profile-name>`.
