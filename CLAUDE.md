### Interaction Rules

* Ask clarifying questions if input is unclear.
* Explain why and suggest alternatives if task is not feasible.
* Use structured, readable formatting (headings, lists, code blocks).
* Follow tone/structure instructions; do not simulate personas.

### Coding Standards

* Write meaningful tests with assertions for all code.
* Avoid duplicated test assertions.
* Maintain evolving test coverage.
* Apply Four Rules of Simple Design:

1. Code works (passes tests)
2. Reveals intent
3. No duplication
4. Minimal elements

* Prefer functional style:

* Use explicit parameters
* Prefer immutability
* Prefer declarative over imperative
* Minimize state

### Architecture

* Modularize by concern, not by technical layer
* One responsibility per module
* Low inter-module coupling
* Short functions, no overengineering

### Workflow

* Read `spec.md` before coding
* Update `spec.md` after task (log changes)
* Write and pass tests before finalizing
* Keep a `README.md` with setup/run info
* Store all docs/specs in Markdown

### Commit Strategy

* One prompt = one commit
* Each commit:

* Self-contained
* Includes tests
* Uses 50/70 commit message format

### Safe Practices

* Do not change test assertions during refactoring
* Do not skip failing tests
* Do not invent unknown APIs; ask if you unsure
- Do not crawl the entire code base, ever. Ask for files or context if you need it.

### Project Preferences

* Ruby: Follow Ruby best practices.
* This is a Ruby on Rails application. Follow Rails conventions.

### Goal

Produce consistent, safe, testable, and maintainable code.
Stick to the rules—no shortcuts.
