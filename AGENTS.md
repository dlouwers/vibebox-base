**Objective:** Create a reusable, open-source "VibeBox Base" Docker image. This image will serve as a secure foundation for Vibe Coding agents, decoupling tooling from domain logic.

**Output:** A published multi-arch Docker image on DockerHub (`dlouwers/vibebox-base`) supporting AMD64 and ARM64 architectures, updated automatically via GitHub Actions.

---

## 🛑 CHECKPOINT 1: Human Setup (Required)

*Do not proceed until these steps are marked complete.*

* [x] **Create GitHub Repository:** Create a public empty repository (e.g., `vibebox-base`).
* [x] **Create DockerHub Account:** Ensure you have a valid account at [hub.docker.com](https://hub.docker.com).
* [x] **Generate Access Token:** Go to DockerHub Settings -> Security -> New Access Token (Read/Write/Delete permissions).
* [x] **Set GitHub Secrets:**
* Go to Repo Settings -> Secrets and variables -> Actions -> New Repository Secret.
* `DOCKERHUB_USERNAME`: Your Docker ID.
* `DOCKERHUB_TOKEN`: The Access Token you just generated.
* [ ] **Configure Branch Protection (Optional but Recommended):** See [Branch Protection Setup](#-branch-protection-setup-optional) below.



---

## 🚀 Phase 2: Foundation (Agent Task)

*Create the following files to define the image.*

### 1. `Dockerfile`

Create a `Dockerfile` in the root.
**Requirements:**

* **Base Image:** `mcr.microsoft.com/devcontainers/base:debian-bookworm` (Stable, slim).
* **Labels:** OCI compliant source/description labels.
* **System Deps:** `nodejs`, `npm`, `build-essential` (apt-get).
* **Vibe Tools:** Global install of `opencode-ai` and `vibebox` (npm).
* **Sandbox:** Create directory `/workspaces` with `777` permissions.
* **Entry:** Set `WORKDIR /workspaces` and `CMD ["/bin/bash"]`.

### 2. `vibebox.toml`

Create a default security configuration file in the root.
**Requirements:**

* **Mode:** Strict isolation.
* **Mounts:** Allow `/workspaces` (read-write).
* **Block:** Explicitly block access to root sensitive files (e.g., `/root/.ssh`, `/etc/shadow`).

---

## ⚙️ Phase 3: Automation (Agent Task)

*Set up the CI/CD pipeline to publish the image.*

### 3. `.github/workflows/publish.yml`

Create a GitHub Action workflow.
**Requirements:**

* **Trigger:** On `push` to `main`, `pull_request` to `main`, and `release` tags (`v*`).
* **Permissions:** `contents: read`, `packages: write`.
* **Steps:**
1. Checkout Code.
2. Setup Docker Buildx.
3. Login to DockerHub (using Secrets from Checkpoint 1).
4. Extract Metadata (Tags/Labels).
5. Build and Push to DockerHub.


* **Caching:** Enable GitHub Actions caching for faster builds.

---

## 🛡️ Phase 4: Maintenance (Agent Task)

*Ensure the image stays secure and up-to-date.*

### 4. `.github/dependabot.yml`

Create a Dependabot configuration.
**Requirements:**

* **Docker:** Check for updates to the `mcr.microsoft.com` base image weekly.
* **GitHub Actions:** Check for updates to the CI/CD actions (checkout, build-push, etc.) weekly.

---

## ✅ CHECKPOINT 5: Final Review (Human)

*Review the Agent's work before merging.*

* [x] **Verify Files:** Check that `Dockerfile`, `vibebox.toml`, and `.github/` folders exist.
* [x] **Commit & Push:** Commit the changes to `main`.
* [x] **Verify Build:** Go to the "Actions" tab in GitHub and watch the pipeline run.
* [x] **Verify Registry:** Check DockerHub to confirm the image `vibebox-base:latest` is published.
* [x] **Verify Badges:** Check README.md badges show success (GitHub Actions badge may take 5-10 minutes to update due to caching).

---

## 🔄 Periodic Maintenance

*Ongoing tasks to keep the image healthy and up-to-date.*

### Weekly Checks

* [ ] **Review Dependabot PRs:** Check for automated dependency update PRs and merge if tests pass.
* [ ] **Verify Build Status:** Ensure latest workflow runs are succeeding at https://github.com/dlouwers/vibebox-base/actions
* [ ] **Check Badge Status:** Verify README badges display correctly (green success indicators).
* [ ] **Monitor DockerHub:** Confirm image tags are publishing correctly at https://hub.docker.com/r/dlouwers/vibebox-base

### Monthly Checks

* [ ] **Test Image Pull:** Run `docker pull dlouwers/vibebox-base:latest` and verify it works.
* [ ] **Review Security:** Check for any security advisories on base image or dependencies.
* [ ] **Validate Tools:** Test that `opencode-ai` and `vibebox` commands work inside the container.
* [ ] **DockerHub Token:** Verify Personal Access Token hasn't expired (regenerate if needed).

### When Issues Occur

* **Badge shows failure but build succeeds:** Wait 10 minutes for GitHub cache to refresh.
* **Build fails with "image not found":** Check base image tag is valid at https://mcr.microsoft.com
* **DockerHub push fails:** Verify `DOCKERHUB_TOKEN` secret is valid and has write permissions.
* **Dependabot PRs fail:** Review logs to identify if base image or action version has breaking changes.
* **Multi-arch build takes longer:** Building for both AMD64 and ARM64 typically takes 3-5 minutes (normal).

---

## 🔒 Branch Protection Setup (Optional)

*Recommended for production repositories to prevent accidental force pushes and ensure code review.*

### Why Branch Protection?

Branch protection rules enforce quality gates on the `main` branch:
- Prevents direct pushes (requires pull requests)
- Requires code review approvals before merge
- Ensures CI/CD checks pass before merge
- Requires conversation resolution
- Protects against accidental history rewrites

### Manual Setup Instructions

**Step 1: Navigate to Settings**
1. Go to https://github.com/dlouwers/vibebox-base
2. Click **Settings** tab (requires owner/admin access)
3. Click **Branches** in the left sidebar

**Step 2: Add Branch Protection Rule**
1. Click **Add rule** or **Add branch protection rule**
2. In **Branch name pattern**, enter: `main`

**Step 3: Configure Protection Rules**

Enable these recommended settings:

**Required Approvals:**
- ☑ **Require a pull request before merging**
  - ☑ Require approvals: `1`
  - ☑ Dismiss stale pull request approvals when new commits are pushed
  - ☑ Require review from Code Owners (optional, requires CODEOWNERS file)

**Status Checks:**
- ☑ **Require status checks to pass before merging**
  - ☑ Require branches to be up to date before merging
  - In the search box, type `build` and select the GitHub Actions workflow check

**Additional Protections:**
- ☑ **Require conversation resolution before merging**
- ☑ **Require signed commits** (optional, recommended for security)
- ☑ **Include administrators** (applies rules to repo admins too)
- ☑ **Restrict who can push to matching branches** (optional, for team repositories)

**Step 4: Save**
Click **Create** at the bottom.

### Testing Branch Protection

After enabling, verify it works:

```bash
# Create a test branch
git checkout -b test-branch-protection

# Make a small change
echo "# Test" >> README.md
git add README.md
git commit -m "Test branch protection"
git push origin test-branch-protection

# Try to push directly to main (should fail)
git checkout main
git merge test-branch-protection
git push origin main  # Should be rejected
```

**Expected Result:** Direct push to `main` is rejected. You must create a pull request instead.

### Best Practices

1. **Enable Early:** Set up branch protection before inviting collaborators.
2. **Include Admins:** Check "Include administrators" to ensure everyone follows the same process.
3. **Status Checks:** Always require CI/CD checks to pass (prevents broken builds).
4. **Code Owners:** For larger teams, create a `.github/CODEOWNERS` file to auto-assign reviewers.
5. **Signed Commits:** Require GPG/SSH signed commits for supply chain security.

### Branch Protection for Teams

For multi-person teams, consider additional settings:

**Require Multiple Approvals:**
- Set "Require approvals" to `2` or more for critical repositories

**Restrict Push Access:**
- Use "Restrict who can push to matching branches" to limit who can bypass PR requirements

**Code Owners:**
Create `.github/CODEOWNERS`:
```
# Dockerfile and CI/CD changes require security team review
Dockerfile @security-team
.github/ @devops-team

# Everything else requires at least one maintainer review
* @maintainers
```

### Automation (Advanced)

For organizations managing multiple repositories, automate branch protection using GitHub API:

```bash
# Using GitHub CLI (requires gh auth login)
gh api repos/dlouwers/vibebox-base/branches/main/protection \
  --method PUT \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["build"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "required_conversation_resolution": true
}
EOF
```

**Note:** API automation requires a Personal Access Token with `repo` scope.

### Troubleshooting

**"I can't see the Settings tab"**
- You need owner or admin access to the repository.

**"Branch protection rule not enforced"**
- Make sure "Include administrators" is checked if you're testing as an admin.
- Verify the branch name pattern exactly matches `main`.

**"Status check not appearing"**
- The check must run at least once before it appears in the list.
- Push a commit to trigger the GitHub Actions workflow, then return to configure branch protection.

**"Can't merge PR even though checks passed"**
- Check if "Require branches to be up to date" is enabled. If so, rebase your PR branch.
- Ensure all required conversations are resolved.

