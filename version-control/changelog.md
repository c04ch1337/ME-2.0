# Changelog for ME-2.0

## v1.3 (2025-10-21)
### Security & Build Hardening
- **Dockerfiles**: Pinned base images to `python:3.12.6-slim` for reproducibility
- **Dockerfiles**: Added non-root user (UID 10001 `appuser`) and dropped privileges in all images
- **Dockerfiles**: Fixed inline comments (moved to separate lines to avoid parser issues)
- **Dockerfiles**: Added git installation for VCS-based pip installs
- **Dockerfiles**: Implemented proper cleanup of apt lists and build artifacts
- **Compose**: Added healthchecks (TCP/HTTP) for all services (n8n, ollama, mem0, agents, bolna)
- **Compose**: Added restart policies (unless-stopped for prod, on-failure:3 for dev)
- **Compose**: Fixed invalid YAML sequences and normalized list formatting
- **Compose**: Bound laptop services to localhost (127.0.0.1) for dev security

### Build Correctness
- **Compose**: Corrected build contexts and dockerfile paths (mem0 uses scripts/, agents/bolna use repo root)
- **Compose**: Fixed `depends_on` syntax (converted to proper YAML list)
- **Compose**: Normalized GPU device configuration indentation
- **Dockerfile.agents**: Implemented production-ready installation of strix/factory/chatrouter from GitHub sources
- **Dockerfile.bolna**: Fixed to install bolna from GitHub (not on PyPI)
- **Dockerfile.mem0**: Kept COPY path consistent with scripts/ build context

### Scripts & Setup
- **setup_ubuntu.sh**: Fixed shebang position, added set -euo pipefail and DEBIAN_FRONTEND=noninteractive
- **setup_ubuntu.sh**: Replaced deprecated apt-key with modern signed keyrings for NVIDIA Container Toolkit
- **setup_ubuntu.sh**: Added Node.js 20 installation via NodeSource
- **setup_ubuntu.sh**: Commented all section markers to prevent command-not-found errors
- **setup_laptop.ps1**: Added Set-StrictMode and $ErrorActionPreference = "Stop" for error handling
- **agent_orchestrator.py**: Parameterized service URLs (CHATROUTER_URL, MEM0_URL) for Compose DNS compatibility
- **cleanup_ubuntu_nvidia.sh**: New script to clean legacy ubuntu18.04 NVIDIA repos and set up toolkit for Ubuntu 22.04/24.04
- **bootstrap_ubuntu2204.sh**: New one-command bootstrap script for Ubuntu setup

### Supporting Files
- **.dockerignore**: Added at repo root to exclude VCS, caches, envs, docs, secrets from build contexts
- **scripts/.dockerignore**: Added minimal context filter for mem0 builds (only run_mem0.py)

### Documentation
- **README.md**: Added comprehensive "Agent Frameworks Installation" section with production and development strategies
- **README.md**: Added troubleshooting subsection covering build failures, runtime issues, version conflicts, debugging tips
- **README.md**: Documented volume mount strategy for development iteration
- **README.md**: Added hybrid deployment approach (docker-compose.override.yml pattern)

### Database Recommendation
- Recommended Supabase (managed Postgres with pgvector) for DreamLit integration
- Documented initial setup checklist and baseline schema considerations
- Added environment variable configuration for DATABASE_URL, SUPABASE_URL, and keys

### Known Issues Resolved
- Fixed NodeSource GPG key verification issues (cleanup script removes stale keys and re-adds properly)
- Fixed bolna GitHub branch (repo uses default branch, not 'main')
- Fixed mem0 COPY path mismatch (aligned with scripts/ build context)
- Fixed strix/factory/chatrouter PyPI 404 errors (installed from GitHub sources)

## v1.2 (2025-10-20)
- Made all docs/README more concise: Trimmed sections, shortened language, improved scannability per best practices.

## v1.1 (2025-10-20)
- Renamed to ME-2.0.

## v1.0 (2025-10-20)
- Initial.