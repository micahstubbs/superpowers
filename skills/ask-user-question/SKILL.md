---
name: ask-user-question
description: Use when the user says "interview me", "ask me questions about", "use the ask user skill", "use your interview skill", or when requirements are ambiguous and need guided option-based clarification before planning or execution.
---

# Ask User Question

## Overview

Use a structured interview to collect missing context before planning or executing work. Ask informed, option-based questions with clear tradeoffs, then wait for answers before proceeding.

In Codex, use `request_user_input` when the tool is available in the current mode. If the tool is unavailable, ask the same question in markdown and wait for the user's reply.

## Interview Workflow

### 1. Explore before asking

- Inspect the codebase, docs, existing patterns, and recent context first.
- Note constraints, conventions, and likely decision points.
- Do not ask blind questions that basic discovery can answer.

### 2. Identify critical decisions

- Focus on choices that affect architecture, scope, user experience, data shape, dependencies, or rework risk.
- Skip implementation details until the direction is clear.
- Ask only what is needed to unblock the next concrete step.

### 3. Design structured questions

- Ask one question at a time by default.
- Provide 2-4 mutually exclusive options with tradeoffs.
- Lead with a recommended option based on discovery.
- Make options concrete and actionable, not abstract preferences.

### 4. Ask and wait

- Use `request_user_input` if available.
- Do not proceed until the user answers, declines, or explicitly asks you to continue with best judgment.
- If the answer creates new unknowns, ask the next question.

### 5. Move forward when clear

When clarity is sufficient, summarize the decisions and move to the appropriate next workflow: brainstorming, planning, implementation, documentation, or issue creation.

## Question Design Rules

- Keep question headers 12 characters or fewer.
- Use short option labels.
- Explain each option's impact or tradeoff in one sentence.
- Put the recommended option first and label it `(Recommended)`.
- Use `multiSelect: false` unless multiple choices can legitimately apply.
- Prefer single-question turns unless batching is explicitly requested or materially reduces churn.

## Codex Tool Usage

When `request_user_input` is available, use one question with this shape:

```text
question: specific question with context
header: short tag, max 12 chars
options:
  - label: "Option name (Recommended)"
    description: "Why this fits and the tradeoff."
  - label: "Alternative"
    description: "Why someone would choose this and the tradeoff."
```

Do not include an `Other` option when using `request_user_input`; Codex adds free-form Other automatically.

## Markdown Fallback

If `request_user_input` is unavailable or the current mode forbids it, ask one concise markdown question:

```markdown
**Header:** Specific question with context?

1. **Option name (Recommended)** - Why this fits and the tradeoff.
2. **Alternative** - Why someone would choose this and the tradeoff.
3. **Narrower option** - What gets deferred or simplified.
4. **Other** - Describe your preferred direction.
```

Wait for the user's answer before continuing.

## Avoid

- Do not ask multiple interview questions in one turn unless explicitly requested.
- Do not auto-select an answer for the user.
- Do not use generic "what do you want?" questions when repository discovery can produce concrete options.
- Do not continue the interview after the user has enough clarity for the next workflow.
