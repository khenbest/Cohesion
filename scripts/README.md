# Scripts Directory - Runtime Scripts for Cohesion

**PURPOSE:** Scripts that cohesion CLI calls at runtime
**STATUS:** ACTIVE (but minimal)

## Current Scripts

These scripts are called by the cohesion binary:

### cohesion-doctor.sh
- **Called by:** `cohesion doctor`
- **Purpose:** Diagnose installation issues
- **Status:** Active

### cohesion-learn.sh
- **Called by:** `cohesion learn`
- **Purpose:** Interactive learning about Cohesion principles
- **Status:** Active

### cohesion-uninstall-global.sh
- **Called by:** Install process (copied to ~/.cohesion/bin/)
- **Purpose:** Uninstall global Cohesion installation
- **Status:** Active

## Removed Legacy Scripts

The following were removed on 2025-09-10 (archived in z/archive/legacy-scripts-20250910/):
- **cohesion-merge-settings.sh** - Obsolete settings merger (we use single settings.json now)
- **cohesion-verify-installation.sh** - Replaced by z/active/scripts/fix/verify.sh

## Important Notes

1. These scripts are installed to `~/.cohesion/scripts/` during installation
2. They use the standardized header and source cohesion-utils.sh
3. For development/testing scripts, use `z/active/scripts/` instead

## Future Consideration

These remaining scripts could potentially be:
- Integrated directly into the cohesion binary
- Moved to z/active/scripts/ if they're only for maintenance
- Keep as-is if they're user-facing runtime features

---

*Minimal set of runtime scripts called by cohesion CLI*