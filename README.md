# tcg-sandbox terraform template

A template repository to jump-start your own trading card game using [tcg-sandbox.com](https://tcg-sandbox.com). Replace the placeholder content, add your assets, and run `terraform apply` to launch your game.

## Supercharged by Claude Code

This template and the tcg-sandbox Terraform provider are designed to work hand-in-hand with [Claude Code](https://claude.ai/code) — Anthropic's AI coding agent. With Claude Code, you can describe the card game you want to build in plain language and let it handle the heavy lifting: generating card definitions, writing lore, updating your Terraform configuration, and running the scripts that bring it all to life.

Rather than manually crafting every card and post, you can have a natural conversation with Claude Code about your game's theme, mechanics, and world — and watch it build out your `assets/` directory and infrastructure in real time. It's the fastest way to go from idea to a fully deployed trading card game.

Get started with Claude Code at [claude.ai/code](https://claude.ai/code).

## Getting started

### 1. Sign up and generate an API key

1. Create an account at [tcg-sandbox.com](https://tcg-sandbox.com)
2. Navigate to [https://tcg-sandbox.com/account](https://tcg-sandbox.com/account)
3. Generate an API key from the account page

### 2. Install prerequisites

You'll need the **Terraform CLI** and **jq** installed.

**macOS (Homebrew):**
```bash
brew tap hashicorp/tap && brew install hashicorp/tap/terraform
brew install jq
```

**Linux:**
```bash
# Terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# jq
sudo apt-get install -y jq
```

### 3. Configure your API key

Create a `terraform.tfvars` file in the root of this repo:

```hcl
api_key = "your-api-key-here"
```

> **Note:** `terraform.tfvars` is listed in `.gitignore` — keep your API key out of source control.

### 4. Add your game content

Before applying, customize the placeholder content:

- Replace `assets/banner.png` with your game's banner image
- Edit `assets/rules.md` with your game's rules
- Add lore posts as Markdown files under `assets/lore/`
- Use the provided scripts to create cards:
  ```bash
  ./scripts/create-card.sh
  ```

### 5. Deploy your game

Once your content is ready, initialize Terraform and apply:

```bash
terraform init
terraform apply
```

Review the plan and confirm to create your game on tcg-sandbox.com.
