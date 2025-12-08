
# arc42 Build Process – Requirements (Updated)

## Overview and Goals


This document specifies requirements for a **new automated build process** for the arc42 template.

The goals are:

- Generate the arc42 template in multiple **technical formats** and **natural languages**.
- Support both **plain** and **withHelp** content flavors.
- Use a **modern, maintainable, and reproducible** open-source toolchain.
- Run **locally (via Docker)** and in **cloud-based environments** (e.g., GitHub Codespaces, CI).
- Be easily **extensible** (new formats, new templates such as req42).

This specification is intended to be usable as **input for code generation tools (LLMs)** that help implement the build system.

---

## Context: arc42 Template

arc42 is a lightweight software architecture documentation template, available in multiple natural languages (EN, DE, FR, CZ, ES, IT, NL, PT, RU, UKR, ZH).

- The **English and German** versions are maintained by core committers.
- Other languages are maintained by community contributors and reviewed by the community.

The template is maintained as **AsciiDoc** source files in a GitHub repository:

- Repository: `https://github.com/arc42/arc42-template`

Example structure for a language:

For example, here you find the directory content of the EN version:

```
.
├── EN
│   ├── arc42-template.adoc
│   └── adoc
│       ├── 01_introduction_and_goals.adoc
│       ├── 02_architecture_constraints.adoc
│       ├── 03_context_and_scope.adoc
│       ├── 04_solution_strategy.adoc
│       ├── 05_building_block_view.adoc
│       ├── 06_runtime_view.adoc
│       ├── 07_deployment_view.adoc
│       ├── 08_concepts.adoc
│       ├── 09_architecture_decisions.adoc
│       ├── 10_quality_requirements.adoc
│       ├── 11_technical_risks.adoc
│       ├── 12_glossary.adoc
│       ├── about-arc42.adoc
│       └── config.adoc
│   └── images
│       └── <language-specific-diagrams and images, jpg or png>
└── version.properties
```

### version.properties

Each language directory contains `version.properties`, which defines AsciiDoc attributes for revision metadata, e.g.:

```text
revnumber=9.0-EN
revdate=July 2025
revremark=(based upon the asciidoc version)
```

The build process must read and apply this metadata into generated artifacts.

### Diagrams

Some diagrams (PNG/JPG, often originating from draw.io) are included to explain concepts and views.

- Currently, diagrams reside mainly under a common `/image` directory.
- In the future, diagrams may become **language-specific** and moved into language subdirectories (e.g., `EN/image`, `DE/image`).

The build process must be robust against these layout changes and support both shared and localized diagrams.

---


### Repository Strategy (Decision)

For arc42 (and related templates such as req42), we deliberately choose a **two-repository setup** as the primary and supported model:

1. **Build repository** (e.g. `arc42-build` or `arc42-generator`)
   - Contains all build logic, configuration, Docker setup, and CI workflows.
   - Knows how to fetch or reference one or more template repositories (arc42, req42, etc.).

2. **Template repository** (e.g. `arc42-template`, later also `req42-template`)
   - Contains only content: AsciiDoc sources, diagrams, and `version.properties` per language.
   - Does *not* contain complex build logic beyond minimal helper scripts for local convenience.

The build repository treats templates as **dependencies**. It may reference them via Git submodules or by scripted cloning/checking out of a specific commit, tag, or branch.

From the build system’s point of view, the canonical interface is:

> Given a local path (or Git URL + ref) to a template repository and a configuration file, produce the configured outputs into `dist/`.

Contributors working on content (translations, corrections) primarily interact with the template repository. Core maintainers and release engineers work with the build repository to generate and publish artifacts.

Single-repository setups are not a primary design target for this build system. They can still use the build tooling by treating the template folder as an external input path, but the reference architecture and CI examples assume the two-repository model described above.

---

## Target Outputs

### Technical Formats

For practical use in projects, arc42 must be available in multiple technical formats. 
Each format has a priority (1 = highest).

| Priority | Format                         | Extension   |
|---------:|--------------------------------|------------|
| 1        | HTML                           | `.html`    |
| 1        | Microsoft Word                 | `.docx`    |
| 1        | AsciiDoc.                      | `.adoc`    |
| 1        | PDF                            | `.pdf`     |
| 1        | Markdown                       | `.md`      |
| 2        | Atlassian Confluence XHTML     | `.xhtml`   |
| 3        | LaTeX                          | `.tex`     |
| 3        | reStructuredText               | `.rst`     |
| 3        | Textile                        | `.textile` |

The build process must:

- Support **all priority 1 formats**.
- Support priority 2 and 3 formats **where technically feasible**.
- Allow new formats to be added without major refactoring (e.g., Sphinx-based documentation).

### Content Flavors

For each format and language, two content flavors must be generated:

- **plain**: only section headings and minimal introductory text.
- **withHelp**: full template text including detailed explanations (“help texts”).

Where the technical format allows, **help texts must be visually or structurally distinguishable** from core template content (e.g., via styles, admonitions, or separate sections).

### Output Directory Layout

#### Initial build (non-compressed)
The build process must create a predictable, language- and flavor-specific directory structure, e.g.:

```text
build/
  EN/
    plain/
      html/
      pdf/
      docx/
      markdown/
      ...
    withHelp/
      html/
      pdf/
      docx/
      markdown/
      ...
  DE/
    plain/
      ...
    withHelp/
      ...
```

Within each format directory, filenames must follow a consistent, documented naming convention (e.g., `arc42-template-EN-plain.html`).

#### Distribution build (compressed)

The build process shall compress all generated artifacts per language, flavor, and format into ZIP archives for convenient distribution. ZIP filenames must follow a consistent naming convention:

`arc42-template-<LANG>-<FLAVOR>-<FORMAT>.zip`

Examples:

- `arc42-template-EN-withhelp-docbook.zip`
- `arc42-template-EN-withhelp-docx.zip`
- `arc42-template-DE-withhelp-docbook.zip`
- `arc42-template-DE-withhelp-docx.zip`

The same pattern applies to all supported languages (`EN`, `DE`, `FR`, `ES`, `IT`, `NL`, `PT`, `RU`, `UKR`, `CZ`, etc.), both flavors (`plain`, `withhelp`), and all relevant output formats.

---

## Tooling and Technology Constraints

### Open-Source Only

The build process must use **only open-source tools**, such as:

- AsciiDoc toolchain: `asciidoctor`, `asciidoctor-pdf`, etc.
- Format converters: `pandoc`, etc.
- Scripting/orchestration: `bash`, `python`, `node`, `groovy`, `make`, etc.
- Containerization: `docker`, `docker-compose`.

No proprietary SaaS or closed-source converters may be required.

### Orchestration

The build system should use **a single, clear orchestrator**, such as:

- A Python or Node.js CLI tool, groovy script or
- A Makefile or shell script that invokes tools inside Docker.

The orchestrator is responsible for:

- Reading configuration (languages, formats, flavors).
- Running the pipeline steps (preprocessing, conversion, packaging).
- Producing structured logs and error messages.

---

## Execution Environments

The build process must run in the following environments:

1. **Local development** via Docker (Linux, macOS, Windows):
   - Single command to build all configured outputs, e.g.:
     - `./build.sh` or
     - `docker compose run build`
2. **GitHub Codespaces** or similar cloud dev environments.
3. **Continuous Integration (CI) pipelines**:
   - GitHub Actions.
   - Other CI systems, provided Docker is available.

The project should include example CI workflows (e.g., a GitHub Actions workflow) to demonstrate how to run the build process in CI and publish artifacts.

---

## Configuration Model

### Configuration Format

Build configuration must be externalized in a **human-readable file**, preferably YAML. JSON or Groovy-based configuration is acceptable but not required.

Example configuration:

```yaml
languages: [EN, DE, FR]
formats:
  - html
  - pdf
  - docx
  - markdown
flavors: [plain, withHelp]

options:
  pdf:
    page_size: A4
    font_family: NotoSans
  html:
    split_by_chapter: false
```

### Configurable Dimensions

The configuration must allow:

- **Languages** to build (subset of available languages).
- **Formats** to generate.
- **Flavors** to generate (plain, withHelp, or both).
- Optional **format-specific options**, such as:
  - Page size, fonts for PDF.
  - Single-page vs multi-page for HTML/Markdown.
  - Confluence-specific settings (e.g., space key, anchor strategy).

---

## Functional Requirements

### Core Build Steps

For each selected language, flavor, and format, the build system must:

1. **Load and assemble** all relevant AsciiDoc sources (template, includes, config).
2. **Apply version metadata** from `version.properties`.
3. **Apply flavor-specific filtering** (plain vs withHelp).
4. **Run AsciiDoc-based conversion** to the intermediate or target format.
5. **Convert** using downstream tools where needed (e.g., AsciiDoc → DocBook/HTML → PDF/DOCX via pandoc).
6. **Embed or reference diagrams** as required per format.
7. **Write outputs** to the configured directory structure.

### Preprocessing and Validation

Before conversion, the build process should run a preprocessing/validation phase that:

- Verifies that all `include::` and image references exist.
- Optionally runs AsciiDoc linting (e.g., `asciidoctor-lint` or equivalent).
- Checks that `version.properties` contains required attributes (`revnumber`, `revdate`, etc.).
- Validates that plain/withHelp markers are consistent and can be reliably filtered.

If validation fails, the build should **fail with clear, actionable error messages**.

### Localization and Fonts

The build process must support all configured languages, including those that require non-ASCII characters (e.g., RU, UKR, ZH). For all formats that depend on fonts (PDF, DOCX, some HTML renderings), the build must:

- Use fonts that support the required character sets.
- Provide a way to configure fonts in the build configuration.
- Ensure the resulting documents render the language-specific characters correctly.

### Format-Specific Notes

- **PDF**: Must be generated using a reproducible toolchain (e.g., Asciidoctor PDF or AsciiDoc → DocBook → LaTeX → PDF). Font configuration and page layout must be configurable.
- **DOCX**: May be generated via `pandoc` or another open-source converter. Basic styling is sufficient but should be consistent and readable.
- **HTML (single-page)**: Suitable for static website deployment. Should support anchors and internal navigation for sections.
- **Markdown / GitHub Markdown**: Should target commonly accepted markdown conventions. For GitHub-specific markdown, adjust links/headings as necessary.
- **Confluence XHTML**: Must produce XHTML compatible with Atlassian Confluence import.

Implementation details (e.g. exact command line options or intermediate formats) are left to the implementation phase, as long as these requirements are met.

---

## Quality Requirements

### Reproducibility

- All tools and libraries must be **version-pinned** (e.g., via Docker images or lockfiles).
- Builds must be deterministic for the same commit and configuration.
- The build should not depend on external network resources at runtime (except initial clone/fetch of repositories).

### Maintainability

- The codebase of the build system should be **modular and readable**, avoiding unnecessary complexity.
- Avoid a mixture of too many scripting technologies (e.g., not combining large amounts of shell, Groovy, Gradle, and Python without structure).
- Clear separation of:
  - core orchestration,
  - per-format adapters,
  - configuration handling,
  - validation and testing.

### Extensibility

- It must be straightforward to add:
  - new languages (e.g., a new translation directory),
  - new output formats (by implementing a new adapter),
  - new templates (e.g., req42) that follow a similar source structure.
- Prefer a **plugin-like structure** for format converters:

High-level idea:

- A central orchestrator calls format adapters via a well-defined interface (e.g., `build_format(language, flavor, config, paths)`).
- Each adapter knows how to run its own tools and where to write its output.

### Developer Experience

- The build process must provide a **single entry point** for typical usage, with sensible defaults.
- Documentation must include:
  - how to run a full build,
  - how to build a subset (e.g., “only EN PDF withHelp”),
  - how to add a new language or format,
  - how to run tests and validations.



## Testing and Quality Checks

The build system must provide automated checks, at least:

1. **Smoke tests**:
   - For each supported format, generate an example output for at least one language (e.g., EN).
   - Verify that files are created and non-empty.
2. **Structural checks**:
   - Verify that expected sections exist (e.g., 01–12 for arc42).
   - Check that metadata (revnumber, revdate) is present.

Where possible, tests should be implemented in an automated way (e.g., scripts or unit tests for the orchestrator).

---

## Open Questions and Design Decisions

The following topics must be decided during design/implementation and may lead to additional requirements:

1. **Diagram handling**:
   - Should the build process regenerate diagrams from draw.io sources automatically (if available), or treat images as static?

2. **Diagram localization**:
   - If diagrams contain text: should localized versions be supported and validated (e.g., check that EN/DE/FR diagrams exist)?

3. **Translation synchronization**:
   - Should the build system detect when translations are incomplete or outdated compared to EN/DE? If yes, how strict should this check be (warnings vs. errors)?

4. **PDF toolchain choice**:
   - Use Asciidoctor PDF directly, or go via DocBook/LaTeX → PDF? This impacts font handling and layout flexibility.

5. **Per-format configuration**:
   - To what extent should per-format rendering options (e.g. page size, font, TOC levels) be exposed in the configuration?

6. **Support for additional templates**:
   - How exactly should other templates like req42 be integrated: via configuration, a separate config file, or a separate entry point?
