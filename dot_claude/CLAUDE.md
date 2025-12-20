# Global Development Guidelines

## Language Settings

- Conversation: Respond in Japanese.
- Commit Messages: Write in Japanese, emphasizing "why" the change was made.

# Core Principles

* Follow Kent Beck's Test-Driven Development (`tdd` skill) and Tidy First (`tidying` skill) methodologies as the preferred approach for all development work.
* Document at the right layer: Code → How, Tests → What, Commits → Why, Comments → Why not
* Keep documentation up to date with code changes

## Subagent Utilization Policy

Actively utilize Subagents to save context. The main agent will act as an orchestrator, delegating actual work to Subagents.

### Basic Rules

- As soon as two or more independent tasks arise, immediately delegate them to a Subagent using the Task tool.
- Independent tasks must always be executed in parallel (multiple Task tool calls in a single message).
- Specify `model: opus` for Subagents.
- Leverage background execution (`run_in_background: true`) to run multiple Subagents concurrently.
- Collect the results from Subagents using `TaskOutput` and report them in an integrated manner.

### Tasks Suitable for Subagent Delegation

| Category        | Example Tasks                                       |
|-----------------|-----------------------------------------------------|
| Code Exploration| File search, pattern search, architecture investigation |
| Implementation  | Feature addition, bug fixing, refactoring           |
| Testing         | Test execution, test correction, coverage check     |
| Documentation   | README updates, API documentation creation          |
| Debugging       | Error investigation, log analysis, cause identification |
| Research        | Technology research, library comparison, best practice research |
| Web Search      | Gathering latest information, checking documentation, searching for error solutions |

### Example of Parallel Execution

```
User: "Fix the tests and update the documentation."

→ Launch two Tasks in parallel:
  - Task 1: Fix tests (model: opus, run_in_background: true)
  - Task 2: Update documentation (model: opus, run_in_background: true)
→ Collect results using TaskOutput
→ Integrate and report
```

```
User: "Investigate the new features of React 19 and where they are used in the current codebase."

→ Launch two Tasks in parallel:
  - Task 1: Research new features of React 19 using Web Search
  - Task 2: Explore React-related implementations in the codebase
→ Integrate and report results from both tasks
```

### Role of the Main Agent

- Decompose tasks and assign them to Subagents.
- Integrate results and provide the final report.
- Communicate with the user.
- Manage overall progress.

Do not perform fine-grained file operations or code modifications yourself; leave them to Subagents.

## Hallucination Prevention

- Before mentioning a feature, confirm it in the code. If uncertain, say "I will check" and then investigate.
- Do not invent URLs. Only use URLs provided by the user for testing.
- Before suggesting external URLs to the user, always access them via WebFetch to confirm their existence and functionality. Search results alone are insufficient. Do not suggest URLs that return 401/403/404 errors.
- Minimize API calls. If a single test can confirm something, no further tests are needed. Users pay for API usage.

## Precautions for Web Searches

It is currently 2025. When performing web searches, always include "2025" in the search query. Information from 2024 or earlier is likely to be outdated.
