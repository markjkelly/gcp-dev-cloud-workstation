# Cloud Workstation

Cloud Workstation in GCP with Sway desktop, Nix package manager, and a dev environment — accessible remotely via Chrome Remote Desktop.

## Quick Start

1. Fork and clone this repo.
2. Initialize Terraform and run a two-phase apply in the `terraform/` folder.
3. Deploy configurations via `scripts/deploy-configs.sh`.

## Setup

### Prerequisites

1. A GCP project where you have the **Owner** role.
2. [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.0) and the `gcloud` CLI installed.

### Step 1: Authenticate

Run the following commands to authenticate with GCP and configure Application Default Credentials (ADC):

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

Replace `YOUR_PROJECT_ID` with your actual GCP Project ID.

### Step 2: Provision Network and Artifact Registry

The Cloud Workstation configuration validates that the container image exists in the registry at creation time. Therefore, we must deploy the network and registry first:

1. Navigate to the `terraform/` directory:
   ```bash
   cd terraform
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Apply configurations targeting only the network and Artifact Registry resources:
   ```bash
   terraform apply \
     -var="project_id=YOUR_PROJECT_ID" \
     -target=google_compute_network.workstations_vpc \
     -target=google_compute_subnetwork.workstations_subnet \
     -target=google_compute_router.workstations_router \
     -target=google_compute_router_nat.workstations_nat \
     -target=google_artifact_registry_repository.workstation_images
   ```

### Step 3: Build and Push Custom Image

From the root of the repository, build and push the custom workstation container image using Cloud Build:

```bash
cd ..
gcloud builds submit workstation-image/ \
  --tag="us-central1-docker.pkg.dev/YOUR_PROJECT_ID/workstation-images/dev-workstation:latest" \
  --project="YOUR_PROJECT_ID" \
  --region="us-central1"
```

### Step 4: Deploy Cluster, Configuration, and Workstation

Now, complete the Terraform provisioning to create the cluster, configuration, workstation, and cost-saving daily scheduler:

```bash
cd terraform
terraform apply -var="project_id=YOUR_PROJECT_ID"
```

### Step 5: Deploy Configurations & Initialize Nix

Start the workstation if it's not already running:

```bash
gcloud workstations start sway-workstation \
  --cluster=main-cluster \
  --region=us-central1 \
  --project=YOUR_PROJECT_ID
```

Once started, deploy configurations and initialize the persistent Nix store from the repository root:

```bash
cd ..
bash scripts/deploy-configs.sh -p YOUR_PROJECT_ID --profile full
```

### Step 6: Restart and Connect

Stop and start your workstation to trigger the persistent boot scripts (which mount `/nix`, start the Sway desktop, and run boot checks):

```bash
gcloud workstations stop sway-workstation --cluster=main-cluster --region=us-central1 --project=YOUR_PROJECT_ID
gcloud workstations start sway-workstation --cluster=main-cluster --region=us-central1 --project=YOUR_PROJECT_ID
```

Connect using the web proxy URL outputted by `terraform apply` or retrieve it with:

```bash
gcloud workstations describe sway-workstation \
  --cluster=main-cluster \
  --region=us-central1 \
  --project=YOUR_PROJECT_ID \
  --format="value(host)"
```

Open `https://<host>` in your browser.

### Install Profiles

You can specify a profile when running `deploy-configs.sh` to control which tools are installed:

| Profile | What's Included | Build Time |
|---------|----------------|------------|
| `minimal` | Sway desktop, ZSH, Chrome, Antigravity, dev tools | ~14 min |
| `dev` | minimal + tmux + Claude Code | ~25 min |
| `ai` | dev + AI IDEs + AI CLI tools | ~35 min |
| `full` | Everything including Go, Rust, Python, Ruby | ~55 min |

```bash
# Default (full profile)
bash scripts/deploy-configs.sh -p YOUR_PROJECT_ID --profile full

# AI profile (IDEs + AI tools, no languages)
bash scripts/deploy-configs.sh -p YOUR_PROJECT_ID --profile ai
```

## After Setup

### Start your workstation

The setup script stops the workstation at the end to save costs. Start it when you're ready:

```bash
gcloud workstations start sway-workstation \
  --config=sway-config \
  --cluster=main-cluster \
  --region=us-central1 \
  --project=YOUR_PROJECT_ID
```

### Connect via browser

Get the workstation URL:

```bash
gcloud workstations describe sway-workstation \
  --config=sway-config \
  --cluster=main-cluster \
  --region=us-central1 \
  --project=YOUR_PROJECT_ID \
  --format="value(host)"
```

Open the connection URL in your browser or connect via Chrome Remote Desktop. The Sway desktop loads automatically with 4 pre-launched workspaces.

### Auto-stop

A Cloud Scheduler job stops the workstation daily at **8:00 PM Central** to save costs. Start it manually when you need it.

## What's Included

| Component | Details |
|-----------|---------|
| **Machine** | n2-standard-8 (32GB RAM) |
| **Storage** | 200GB persistent disk (all data survives reboots) |
| **Desktop** | Sway (Wayland) with Tokyo Night theme, accessed via Chrome Remote Desktop |
| **Terminal** | foot terminal, ZSH + Starship prompt, DejaVu Sans Mono font (size 14), tmux with Tokyo Night theme |
| **Fonts** | DejaVu Sans Mono (system), Operator Mono (proprietary OTF), Cascadia Code, Fira Code, JetBrains Mono (via Nix) |
| **Browsers** | Google Chrome, Chromium |
| **IDEs** | VS Code, Cursor, Windsurf, Zed, IntelliJ IDEA, Neovim (custom config) |
| **AI Tools** | Claude Code, Gemini CLI, Codex CLI, OpenCode, Aider, Cody CLI, pi-coding-agent |
| **Languages** | Go (latest), Rust (via rustup), Python 3.12 (via pyenv), Ruby 3.3 (via rbenv), Node.js 22 (via Nix) |
| **Apps** | Antigravity, tmux, ripgrep, fd, jq, ffmpeg, wofi, thunar, clipman |
| **Networking** | Tailscale VPN (opt-in via `~/.env`) |
| **Auto-stop** | Cloud Scheduler stops workstation daily at 8PM Central |
| **Boot apps** | 4 workspaces auto-launch: Antigravity IDE (ws1), VS Code (ws2), terminal (ws3), Chrome (ws4) |
| **Profiles** | Composable install: minimal (14 min), dev, ai, full (55 min) — `--profile` flag |
| **Boot tests** | 160+ automated tests run on every boot — results at `~/logs/boot-test-results.txt` |
| **Packages** | Managed via Nix Home Manager on persistent disk |

## Keyboard Shortcuts

All shortcuts use `CTRL+SHIFT` as the modifier (works through Chrome Remote Desktop).

| Shortcut | Action |
|----------|--------|
| `CTRL+SHIFT+Enter` | New terminal (foot) |
| `CTRL+SHIFT+T` | New terminal (foot) |
| `CTRL+SHIFT+B` | Chrome browser |
| `CTRL+SHIFT+Y` | VS Code |
| `CTRL+SHIFT+W` | Windsurf |
| `CTRL+SHIFT+M` | IntelliJ IDEA |
| `CTRL+SHIFT+R` | App launcher (wofi) |
| `CTRL+SHIFT+A` | Clipboard history (clipman) |
| `CTRL+SHIFT+S` | Snippet picker |
| `CTRL+SHIFT+E` | File manager (thunar) |
| `CTRL+SHIFT+D` | Toggle floating window |
| `CTRL+SHIFT+Q` | Close window |
| `CTRL+SHIFT+F` | Toggle fullscreen |
| `CTRL+SHIFT+H/I/O/P` | Switch to workspace 1/2/3/4 |
| `CTRL+SHIFT+U/J/K/L` | Switch to workspace 5/6/7/8 |
| `CTRL+SHIFT+Alt+H/I/O/P` | Move window to workspace 1/2/3/4 |
| `CTRL+SHIFT+Alt+U/J/K/L` | Move window to workspace 5/6/7/8 |
| `CTRL+SHIFT+Arrow keys` | Focus window left/right/up/down |
| `CTRL+SHIFT+,/.` | Grow/shrink window width |
| `CTRL+SHIFT+-/=` | Shrink/grow window height |
| `CTRL+SHIFT+Escape` | Exit Sway (with confirmation) |

## Language Version Management

Languages are managed by native version managers for easy multi-version support:

| Language | Manager | Switch Versions |
|----------|---------|----------------|
| Go | Direct install | Download from go.dev |
| Rust | rustup | `rustup install nightly` |
| Python | pyenv | `pyenv install 3.11 && pyenv global 3.11` |
| Ruby | rbenv | `rbenv install 3.2.0 && rbenv global 3.2.0` |
| Node.js | Nix | Managed via Home Manager |

## tmux + Claude Code Aliases

The workstation includes crash-resistant tmux sessions pre-configured for Claude Code:

| Alias | Description |
|-------|-------------|
| `t1` through `t10` | Launch Claude Code in named tmux sessions (`claude-1` through `claude-10`) |
| `cc` | Alias for `t1` (quick start) |
| `tdbg` | Launch Claude Code in a debug tmux session with server-level logging to `~/logs/tmux/` |

Sessions use `claude-tmux`, a wrapper that auto-launches `claude --dangerously-skip-permissions` inside tmux. If the session already exists, it reattaches. tmux is configured with Tokyo Night theme, mouse support, true color, and vi copy mode.

## Tailscale VPN (Optional)

Tailscale provides secure SSH access to your workstation without port forwarding or VPNs.

To enable, add these to `~/.env` on your workstation:

```bash
TAILSCALE_AUTHKEY=tskey-auth-xxxxx   # From https://login.tailscale.com/admin/settings/keys
USER_PASSWORD=your-ssh-password       # Optional: sets SSH password for the 'user' account
```

On the next boot, the workstation will:
1. Auto-install Tailscale (if the binary is missing from the ephemeral root disk)
2. Start the Tailscale daemon
3. Authenticate with your auth key
4. Enable Tailscale SSH
5. Set the SSH password (if `USER_PASSWORD` is defined)

You can then SSH via `ssh user@<workstation-tailscale-hostname>`.

## Boot Tests

Every boot runs 160+ automated tests to verify the workstation is healthy. Results are saved to:

- `~/logs/boot-test-results.txt` — full PASS/FAIL/WARN details
- `~/logs/boot-test-summary.txt` — one-line summary (e.g., `PASS: 77 | FAIL: 0 | WARN: 3`)

Tests cover: Nix, Sway, fonts, shell, AI tools, IDEs, languages, keybindings, clipboard, snippets, and more.

## Re-running Setup

The setup is fully **idempotent**. If it fails or you want to update, just run it again:

```bash
bash scripts/ws.sh setup -p YOUR_PROJECT_ID
```

Existing resources are detected and skipped. Only missing components are created.

## Teardown / Cleanup

To delete **all** resources created by setup (workstation, cluster, images, NAT, scheduler):

```bash
bash scripts/ws.sh teardown -p YOUR_PROJECT_ID
```

Add `-y` to skip the confirmation prompt. Add `-w` / `-e` for notifications.

This is useful for:
- Testing setup from scratch
- Cleaning up a project you no longer need
- Freeing GPU quota for another project

After teardown, you can re-run `setup.sh` to recreate everything.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Workstation won't start | Check Cloud Workstation quotas in your region in [Cloud Console](https://console.cloud.google.com/iam-admin/quotas) |
| Build fails mid-way | Re-run `ws.sh setup` — it picks up where it left off (idempotent) |
| Can't connect via Chrome Remote Desktop | Ensure workstation is started, wait 30s for Sway + wayvnc to boot |
| Apps not on workspaces | Wait 15-20s after boot for auto-launch to complete |
| Cloud Shell disconnected | No problem — Cloud Build continues independently. Check progress in Cloud Console |
| IDE keybinding not working | Check `~/logs/boot-test-results.txt` for related FAIL entries |
| Claude Code not working | Ensure `~/.env` has your API keys — it's sourced automatically on boot |
| Boot test failures | Run `cat ~/logs/boot-test-results.txt` to see full PASS/FAIL details |
