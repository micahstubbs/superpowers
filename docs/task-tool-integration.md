# Task Tool Integration Guide

## The Problem

Claude Code's Task tool launches subagents to perform work, but the parent agent often fails to use the results effectively:

**Bad pattern:**
```
Claude: "Let me launch a research agent..."
*launches agent*
*agent completes*
Claude: "The agent finished. What would you like to do next?"
← WASTED WORK! Results not consumed.
```

**Good pattern:**
```
Claude: "Let me launch a research agent..."
*launches agent*
*agent returns findings*
Claude: "Based on the agent's findings: [specific details from report]..."
← RESULTS CONSUMED! Work is used.
```

## Result Consumption Patterns

See [task-result-consumption-patterns.md](task-result-consumption-patterns.md) for the three core patterns.

## Skill Integration

All skills that use the Task tool should include explicit "Result Consumption" sections documenting how to use the subagent's output.

**Template:**

```markdown
## Result Consumption

After the [agent-type] agent completes:

1. **Read the full report** - Don't skip sections
2. **Extract key findings** - [Specific what to look for]
3. **Take action** - [What to do with findings]
4. **Verify completeness** - [How to know you're done]

**Example:**

\```
Agent returned 3 bug candidates. For each:
- Note the file path and line number
- Understand the suspected issue
- Create a targeted fix plan
\```
```

## Verification

Before marking a Task tool usage as complete:

- [ ] Did you read the entire agent response?
- [ ] Did you extract specific details (not just "the agent found some things")?
- [ ] Did you take concrete action based on the findings?
- [ ] Can you articulate what you learned from the agent?

If any answer is "no", you haven't consumed the results yet.
