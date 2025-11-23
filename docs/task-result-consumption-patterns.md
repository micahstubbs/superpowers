# Task Tool Result Consumption Patterns

## Three Core Patterns

### Pattern 1: Direct Action

**Use when:** The subagent produces actionable items.

**Process:**
1. Launch Task agent
2. Agent returns specific items (files, bugs, tasks)
3. **For each item**, take immediate action
4. Verify all items processed

**Example:**

```
Task: Find all TODO comments
Agent returns:
  - src/api.py:42 "TODO: Add validation"
  - src/db.py:103 "TODO: Add index"

Consumption:
  FOR src/api.py:42:
    - Read surrounding code
    - Add validation
    - Remove TODO
  FOR src/db.py:103:
    - Read migration files
    - Create index migration
    - Remove TODO
```

### Pattern 2: Synthesis and Planning

**Use when:** The subagent produces information requiring analysis.

**Process:**
1. Launch Task agent
2. Agent returns findings, research, analysis
3. **Synthesize** findings into coherent understanding
4. **Create plan** based on synthesis
5. **Execute** plan

**Example:**

```
Task: Research authentication patterns
Agent returns: 15-page report on JWT, OAuth, Sessions

Consumption:
  Synthesis:
    - JWT: Stateless, scalable, token management complexity
    - OAuth: Social login, external dependency
    - Sessions: Stateful, simple, scaling challenges

  Decision:
    - Use JWT for API
    - Use sessions for web

  Plan:
    1. Implement JWT for /api/* routes
    2. Implement sessions for web routes
    3. Add refresh token rotation
```

### Pattern 3: Parallel Dispatch and Correlation

**Use when:** Multiple subagents work independently.

**Process:**
1. Launch N Task agents in parallel
2. Each agent returns results
3. **Correlate** results across agents
4. **Identify** patterns, conflicts, gaps
5. **Synthesize** unified understanding
6. Take action

**Example:**

```
Task: Debug production issue
Launch 3 agents:
  - Agent A: Search logs
  - Agent B: Review recent changes
  - Agent C: Check infrastructure

Agent A returns: Error spike at 14:32 UTC
Agent B returns: Deployment at 14:30 UTC
Agent C returns: No infrastructure changes

Correlation:
  - Timing matches: deployment → errors
  - Recent change is suspect

Action:
  - Review deployment diff
  - Identify bug in new code
  - Hotfix deployment
```

## Anti-Patterns

**DON'T:**
- ❌ "The agent completed successfully" (vague)
- ❌ "Agent found some issues" (no specifics)
- ❌ "See the agent's report above" (pass the buck)
- ❌ Launch agent and immediately ask user what to do next

**DO:**
- ✅ "Agent found 3 bugs: (1) null pointer in auth.py:42..."
- ✅ "Based on agent's research, I'll implement JWT because..."
- ✅ "Correlating agent A and B results, the root cause is..."
