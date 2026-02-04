# Update Plan Skill

Create timestamped update directories when plans evolve, preserving both the updated plan and the session conversation that led to the update.

## When This Skill Is Invoked

The user invokes this skill with `/update-plan` followed by the path to the original plan directory.

## Your Task

When this skill is invoked, you must:

1. **Parse the original directory path** provided by the user
2. **Create a new timestamped update directory** with the plan update
3. **Export the current session** to capture the update conversation
4. **Generate documentation** linking the old and new versions
5. **Report success** with clear output showing what was created

## Parameters

Parse these from the user's command:

- `original_dir` (required) - Path to original plan directory (e.g., `exports/sessions/2026-02-03-1647-network-handling`)
- `--rationale` (optional) - Why this update was needed (auto-extract from conversation if not provided)
- `--plan-file` (optional) - Custom plan filename to read from original directory (default: PLAN.md)

## Step-by-Step Process

### 1. Validate Original Directory

```typescript
// Check that the original directory exists
// Find the plan file (PLAN.md or plan.md for backwards compatibility)
// Extract timestamp and topic from directory name
```

Expected directory format: `{YYYY-MM-DD-HHMM}-{topic}/`
Example: `2026-02-03-1647-network-handling/`

Expected plan file: `PLAN.md` (or `plan.md` for backwards compatibility)

If plan file not found, show error:
```
❌ No plan file found in {original_dir}
   Expected: PLAN.md

   Use --plan-file to specify a custom filename if needed.
```

### 2. Generate New Directory Name

Format: `{YYYY-MM-DD-HHMM}-{topic}-update/`

Example:
- `2026-02-04-1523-network-handling-update/`

**IMPORTANT:** Always use the `-update` suffix. This makes it clear that the directory contains a plan update, not a new plan.

If directory exists (same timestamp), append version:
- `2026-02-04-1523-network-handling-update-v2/`
- `2026-02-04-1523-network-handling-update-v3/`

### 3. Create Update Directory Structure

```bash
mkdir -p {new_directory}
```

Parent directory should be same as original (typically `exports/sessions/`)

### 4. Generate Updated Plan from Conversation

Analyze the current conversation to generate the updated plan:

1. **Review the conversation** - Identify what changes, improvements, or refinements were discussed
2. **Read the original plan** (if helpful for context):
   ```bash
   # Read original for reference
   cat {original_dir}/PLAN.md
   ```
3. **Generate the updated plan** - Create a fresh plan document that incorporates:
   - All changes and refinements discussed in this conversation
   - The evolved approach or strategy
   - Any new insights or decisions made
4. **Save to new directory as PLAN.md**:
   ```bash
   # Write the updated plan
   {new_dir}/PLAN.md
   ```

**IMPORTANT:**
- The updated plan is generated from THIS conversation, not copied from the original
- Always save as `PLAN.md` for consistency
- The original plan in the original directory remains untouched

### 5. Export Current Session

Generate session files to capture this update conversation:

1. **Write session.json** - Create a JSON file with the conversation structure:
   ```json
   {
     "metadata": {
       "exportedAt": "[current date/time]",
       "workingDirectory": "[current working directory]"
     },
     "messages": [
       {
         "role": "user",
         "content": "User's message text"
       },
       {
         "role": "assistant",
         "content": "Simple text response"
       },
       {
         "role": "assistant",
         "content": [
           {"type": "text", "text": "Response with tool uses"},
           {
             "type": "tool_use",
             "name": "ToolName",
             "input": {"param": "value"},
             "output": "Tool output text"
           },
           {"type": "text", "text": "More response text"}
         ]
       }
     ]
   }
   ```
   Save to: `{new_dir}/session.json`

   **Content Rules:**
   - **User messages**: Always a string
   - **Assistant messages**: String for text-only, array for responses with tool uses
   - **Tool uses**: Include type, name, input parameters, and output
   - **Large outputs**: Truncate to ~2000 chars with `[... truncated]`
   - **Sensitive data**: Replace API keys/passwords with `[REDACTED]`

2. **Generate session.html** - Run the export script:
   ```bash
   python3 ~/.claude/skills/export-session/export.py "{new_dir}/session.json" "{new_dir}/session"
   ```
   This creates `{new_dir}/session.html` from the JSON.

**Important:**
- Reconstruct the ENTIRE conversation from the beginning of this session
- Include ALL messages and tool uses in session.json
- Follow the exact content rules above for proper tool call recording

If export fails, continue anyway and note in UPDATE_RATIONALE.md:
```markdown
**Note:** Session export failed - see conversation in Claude Code history
```

### 6. Generate UPDATE_RATIONALE.md

Create `{new_dir}/UPDATE_RATIONALE.md`:

```markdown
# Plan Update Rationale

**Original Plan:** ../{original_dir_name}/
**Updated:** {YYYY-MM-DD HH:MM}

## What Changed

{Extract key changes from conversation or plan diff - e.g., "Simplified from complex guards to communication-first approach"}

## Why This Update

{rationale from --rationale flag or extracted from conversation}

## Key Insights

{Extract important quotes or realizations from the conversation}

## Impact

{Brief summary of implications - code changes, approach shifts, etc.}
```

**Auto-extraction tips:**
- Look for phrases like "changed from X to Y", "simplified", "removed", "added"
- Quote key user statements about why the update was needed
- Identify trade-offs discussed in the conversation

### 7. Create SUPERSEDED.md in Original Directory

Create `{original_dir}/SUPERSEDED.md`:

```markdown
# Plan Superseded

This plan has been updated. See latest version at:

**Latest:** ../{new_dir_name}/

**Reason:** {brief one-line reason}

**Date:** {YYYY-MM-DD}
```

**IMPORTANT:** Use relative paths (../) not absolute paths

If SUPERSEDED.md already exists (multiple updates), update it to point to the latest:
```markdown
# Plan Superseded

This plan has been updated multiple times. See latest version at:

**Latest:** ../{newest_dir_name}/

**Previous updates:**
- ../{older_update_1}/
- ../{older_update_2}/

**Date:** {YYYY-MM-DD}
```

### 8. Output Summary

Show clear success message:

```
✅ Plan updated successfully!

📁 New directory: exports/sessions/2026-02-04-1523-network-handling-update/

Created files:
  ✓ PLAN.md (updated approach)
  ✓ session.html (this conversation)
  ✓ session.json
  ✓ UPDATE_RATIONALE.md (what changed and why)

📎 Original plan marked as superseded:
  ✓ exports/sessions/2026-02-03-1647-network-handling/SUPERSEDED.md

🔗 Links:
  Original → New: SUPERSEDED.md
  New → Original: UPDATE_RATIONALE.md
```

## Edge Cases

### Multiple Updates to Same Plan

Each update creates a new directory. Chain them:

```
Original (v1) → SUPERSEDED.md points to v3 (latest)
Update (v2)   → SUPERSEDED.md points to v3 (latest)
Update (v3)   → UPDATE_RATIONALE.md references v2
```

### Directory Name Collision

If timestamp collision occurs (rare), append version:
- `-v2`, `-v3`, etc.

### Missing Rationale

If user doesn't provide `--rationale`, extract from conversation:
- Look for statements explaining the change
- Quote key insights or realizations
- Summarize the discussion that led to the update

### Custom Plan Filename

If `--plan-file` is provided, read from that file in the original directory but always save as `PLAN.md` in the new directory:
- Read from: `{original_dir}/{custom-name}.md`
- Save as: `{new_dir}/PLAN.md`

## Interactive Mode (Optional)

If invoked without required parameters, prompt:

```
📋 Update Plan

Original plan directory: [prompt user]
Rationale: [Auto-extract from conversation? (y/n)]

Proceed? (y/n):
```

## Error Handling

**Original directory not found:**
```
❌ Directory not found: {original_dir}

   Please check the path and try again.
```

**No plan file:**
```
❌ No plan file found in {original_dir}
   Expected: plan.md or PLAN.md

   Use --plan-file to specify a custom filename.
```

**Permission errors:**
```
❌ Cannot write to {directory}

   Check file permissions and try again.
```

## Example Invocations

### Minimal
```
/update-plan exports/sessions/2026-02-03-1647-network-handling
```

You should:
- Create directory with `-update` suffix
- Auto-extract rationale from conversation
- Auto-detect plan file

### With Rationale
```
/update-plan exports/sessions/2026-02-03-1647-network-handling \
  --rationale "Shifted from complex guards to communication-first approach after realizing transparent communication > complex prevention"
```

You should:
- Create directory with `-update` suffix
- Use provided rationale in UPDATE_RATIONALE.md
- Auto-detect plan file

### Custom Plan File
```
/update-plan exports/sessions/2026-02-03-1647-network-handling \
  --plan-file "custom-plan-name.md"
```

You should:
- Read from the custom-named plan file in original directory
- Generate updated plan and save as PLAN.md in new directory

## Success Criteria

✅ New directory created with `-update` suffix and correct timestamp
✅ Updated plan copied with original filename preserved
✅ Session artifacts saved (HTML + JSON)
✅ UPDATE_RATIONALE.md generated with meaningful content
✅ SUPERSEDED.md created/updated in original directory
✅ All paths are relative (portable across systems)
✅ Clear console output showing what was created
✅ No data loss - original plan remains untouched

## Related Skills

This skill complements:
- `/export-session` - Export current session
- `/export-session-plan` - Export session with plan
- `/implement` - Execute approved plan
- `/plan` - Enter planning mode

Typical workflow:
```
/plan → /export-session-plan → [discussion] → /update-plan → /implement
```
