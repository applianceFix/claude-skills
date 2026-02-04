# `/update-plan` Skill Plan

**Created:** 2026-02-04
**Purpose:** Create timestamped update directories when plans evolve, preserving both the updated plan and the session conversation that led to the update.

## Problem Statement

When a plan is updated after initial creation, the original session artifacts (session.html, session.json) become stale - they capture the original planning conversation, not the update discussion. This makes it hard to:

- Trace how and why the plan evolved
- Debug "which version did we implement?"
- Learn from the decision-making process
- Understand what triggered the change

## Solution

A `/update-plan` skill that creates a new timestamped directory containing:
- Updated plan content
- Current session artifacts (the update conversation)
- Rationale document explaining what changed and why
- Clear lineage to the original plan

## Workflow Example

**Original Plan:**
```
exports/sessions/2026-02-03-1647-network-handling/
├── plan.md                    # Complex approach
├── session.html               # Original planning session
└── session.json
```

**After Update:**
```
exports/sessions/
├── 2026-02-03-1647-network-handling/           # Original
│   ├── plan.md                                 # Complex approach
│   ├── session.html                            # Original planning
│   ├── session.json
│   └── SUPERSEDED.md                           # Points to update
│
└── 2026-02-04-1523-network-handling-update/    # Update
    ├── plan.md                                 # Simplified approach
    ├── session.html                            # Update conversation
    ├── session.json
    └── UPDATE_RATIONALE.md                     # What changed & why
```

## Directory Structure (Recommended: Option 1 - Sequential Updates)

**Benefits:**
- Clear separation of planning sessions
- Easy to find "what was the thinking at this time?"
- Self-contained (directory = complete context)
- Scales well (multiple updates over time)

**Alternatives Considered:**

**Option 2: Nested Updates**
```
└── 2026-02-03-1647-network-handling/
    ├── plan.md (latest)
    └── updates/
        └── 2026-02-04-1523-simplification/
```
*Cons:* Harder to discover, nesting depth grows

**Option 3: Versioned Plans**
```
└── 2026-02-03-1647-network-handling/
    ├── PLAN.md (latest)
    ├── plan-v1-complex.md
    ├── plan-v2-simplified.md
    ├── session-v1.html
    └── session-v2.html
```
*Cons:* Single directory gets cluttered, harder to isolate sessions

## Skill Interface

### Command
```bash
/update-plan
```

### Parameters

**Required:**
- `original_dir` - Path to original plan directory (e.g., `exports/sessions/2026-02-03-1647-network-handling`)

**Optional:**
- `description` - Short description of update (e.g., "simplification", "revised-approach")
  - Default: "update"
- `rationale` - Why this update was needed
  - Default: Extracted from current conversation context
- `plan_file` - Name of plan file to copy
  - Default: "plan.md" or "PLAN.md" (auto-detect)

### Example Usage

**Minimal:**
```bash
/update-plan exports/sessions/2026-02-03-1647-network-handling
```

**With Description:**
```bash
/update-plan \
  exports/sessions/2026-02-03-1647-network-handling \
  --description "simplification"
```

**Full:**
```bash
/update-plan \
  --original exports/sessions/2026-02-03-1647-network-handling \
  --description "simplification" \
  --rationale "Shifted from complex guards to communication-first approach after realizing transparent communication > complex prevention"
```

### Interactive Mode

If parameters are missing, prompt user:
```
📋 Update Plan

Original plan directory: exports/sessions/2026-02-03-1647-network-handling
Update description: [simplification]
Rationale: [Enter rationale or press enter to auto-extract from conversation]

Proceed? (y/n):
```

## Implementation Requirements

### Inputs
1. **Original directory path** - Validate it exists and contains a plan file
2. **Update description** - Sanitize for filename use
3. **Rationale** (optional) - Can be provided or extracted from conversation

### Processing Logic

1. **Parse Original Directory:**
   - Extract timestamp: `2026-02-03-1647`
   - Extract topic: `network-handling`
   - Detect plan filename: `plan.md` or `PLAN.md`

2. **Generate New Directory Name:**
   - Format: `{YYYY-MM-DD-HHMM}-{topic}-{description}/`
   - Example: `2026-02-04-1523-network-handling-simplification/`
   - If description is "update" (default), omit: `2026-02-04-1523-network-handling-update/`

3. **Create New Directory:**
   - Path: Same parent as original (typically `exports/sessions/`)
   - Create directory if it doesn't exist

4. **Copy Updated Plan:**
   - Source: Updated plan from original directory
   - Destination: `{new_dir}/plan.md`

5. **Export Current Session:**
   - Generate: `session.html` (conversation transcript)
   - Generate: `session.json` (structured data)
   - Save both to new directory

6. **Create UPDATE_RATIONALE.md:**
   ```markdown
   # Plan Update Rationale

   **Original Plan:** ../2026-02-03-1647-network-handling/
   **Updated:** 2026-02-04 15:23
   **Update Type:** simplification

   ## What Changed

   - Removed: ConnectionRequiredOverlay component
   - Removed: useIsOnline hook
   - Removed: Complex guards on all dropdowns
   - Added: Loading state in NetworkContext
   - Added: Blue banner for API calls in progress
   - Simplified: Communication-first approach

   ## Why This Update

   {rationale from user input or extracted from conversation}

   ## Key Insight

   > "If lag occurs due to network issues, at least the user knows from the banner that the application is trying to make a network access."

   Transparent communication > Complex prediction and prevention

   ## Impact

   - 50% less code
   - Clearer user communication
   - Same UX with simpler implementation
   ```

7. **Create SUPERSEDED.md in Original Directory:**
   ```markdown
   # Plan Superseded

   This plan has been updated. See latest version at:

   **Latest:** ../2026-02-04-1523-network-handling-simplification/

   **Reason:** Simplified approach using communication-first strategy instead of complex guards

   **Date:** 2026-02-04
   ```

8. **Output Summary:**
   ```
   ✅ Created: exports/sessions/2026-02-04-1523-network-handling-simplification/
     ✓ plan.md (updated approach)
     ✓ session.html (this conversation)
     ✓ session.json
     ✓ UPDATE_RATIONALE.md
     ✓ Link to original: ../2026-02-03-1647-network-handling/

   ✅ Marked original as superseded
   ```

## File Templates

### UPDATE_RATIONALE.md Template

```markdown
# Plan Update Rationale

**Original Plan:** {relative_path_to_original}
**Updated:** {YYYY-MM-DD HH:MM}
**Update Type:** {description}

## What Changed

{auto-generate diff or bullet points of changes}

## Why This Update

{rationale from user or extracted from conversation}

## Key Insights

{extract important quotes or realizations from conversation}

## Impact

{brief summary of implications - code changes, approach shifts, etc.}
```

### SUPERSEDED.md Template

```markdown
# Plan Superseded

This plan has been updated. See latest version at:

**Latest:** {relative_path_to_new_directory}

**Reason:** {brief_reason}

**Date:** {YYYY-MM-DD}
```

## Edge Cases to Handle

### 1. Multiple Updates to Same Plan
**Scenario:** User updates the same plan twice

**Solution:**
- Each update gets a new timestamped directory
- SUPERSEDED.md in original points to **latest** update
- Each UPDATE_RATIONALE.md links to its immediate predecessor

**Example:**
```
├── 2026-02-03-1647-network-handling/         # Original
│   └── SUPERSEDED.md → points to v3
├── 2026-02-04-1523-network-handling-update/  # v2
│   └── SUPERSEDED.md → points to v3
└── 2026-02-05-0900-network-handling-update/  # v3 (latest)
    └── UPDATE_RATIONALE.md → references v2
```

### 2. Plan File Not Found
**Scenario:** Original directory exists but no plan.md or PLAN.md

**Solution:**
- Error message: "No plan file found in {original_dir}. Expected plan.md or PLAN.md"
- Prompt: "Specify plan filename manually? (y/n)"

### 3. Update Directory Already Exists
**Scenario:** Timestamp collision (rare but possible)

**Solution:**
- Append `-v2`, `-v3`, etc.
- Example: `2026-02-04-1523-network-handling-update-v2/`

### 4. Session Export Fails
**Scenario:** Cannot export current session (permission issues, etc.)

**Solution:**
- Create directory and copy plan anyway
- Add note in UPDATE_RATIONALE.md: "Session export failed - see conversation in Claude Code history"

### 5. Relative Path Handling
**Scenario:** Links between directories need to work regardless of where repo is cloned

**Solution:**
- Always use relative paths in SUPERSEDED.md and UPDATE_RATIONALE.md
- Example: `../2026-02-03-1647-network-handling/` not absolute paths

## Success Criteria

✅ New directory created with timestamp and description
✅ Updated plan copied to new directory
✅ Session artifacts (HTML + JSON) saved
✅ UPDATE_RATIONALE.md generated with:
   - Link to original
   - Summary of changes
   - Rationale for update
✅ SUPERSEDED.md created in original directory
✅ All paths are relative (portable)
✅ Clear console output showing what was created

## Implementation Notes

### Technology
- Language: TypeScript/JavaScript (matches existing Claude Code skills)
- Claude Code Skill SDK
- File system operations (mkdir, copyFile, writeFile)
- Session export API (if available)

### Dependencies
- Access to current conversation/session data
- File system permissions in exports/sessions/
- Timestamp generation (system time)

### Testing
Test cases:
1. ✅ First update to a plan
2. ✅ Second update to same plan (chaining)
3. ✅ Update with custom description
4. ✅ Update with custom rationale
5. ✅ Missing plan file (error handling)
6. ✅ Directory collision (versioning)
7. ✅ Relative path correctness

## Future Enhancements

### Phase 2 (Optional)
- **Visual Timeline:** Generate a timeline view of all plan versions
- **Diff View:** Auto-generate diff between plan versions
- **Merge Support:** Merge updates back to original if user prefers single directory
- **Archive Old Versions:** Move superseded plans to `exports/archive/`

### Phase 3 (Optional)
- **Plan Graph:** Visualize plan evolution tree (if multiple branches)
- **Smart Extraction:** Use LLM to extract "what changed" automatically from plan diffs
- **Status Tracking:** Mark plans as "draft", "approved", "implemented", "superseded"

## Related Workflows

This skill complements:
- `/export-session-plan` - Creates initial plan from session
- `/implement` - Executes approved plan
- `/plan` - Enters planning mode

**Workflow Integration:**
```
/plan → /export-session-plan → [discussion] → /update-plan → /implement
```

## Questions for Implementation

1. **Session Export API:** Does Claude Code expose session export functionality to skills?
2. **Plan Diff:** Should we auto-generate diff or rely on user to describe changes?
3. **Format:** Markdown for all docs or support other formats?
4. **Notifications:** Should we notify user if original plan is part of an active branch/PR?

---

**Next Steps:**
1. Implement basic version (create directory, copy files, generate templates)
2. Test with real plan updates
3. Iterate based on usage
4. Add enhancement features (diff, timeline, etc.)
