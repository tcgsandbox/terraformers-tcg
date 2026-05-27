# tcg-sandbox game development guide

This repo is a Terraform template for building and deploying a trading card game on tcg-sandbox.com. It is designed to be used with Claude Code — describe your game in plain language and Claude will guide you through building it.

## How this repo works

- **`main.tf`** — defines the game, its attributes, board layout, rules, and display options via the tcg-sandbox Terraform provider
- **`assets/sets/base/cards.json`** — array of card objects; Terraform reads this dynamically to create/update cards
- **`assets/lore/*.md`** — each file becomes a lore post on tcg-sandbox.com; filename (underscores→spaces, title case) becomes the post title
- **Scripts** — `create-card.sh` and `delete-card.sh` handle card CRUD by editing `cards.json`
- `terraform apply` deploys everything to tcg-sandbox.com

## Asset map

| Path | Purpose |
|---|---|
| `assets/banner.png` | Game banner — replace with your own image |
| `assets/rules.md` | Game rules in markdown — replace placeholder content |
| `assets/lore/*.md` | Lore posts — add files here, remove `placeholder-story.md` |
| `assets/sets/base/cards.json` | Card data array — managed via scripts |
| `assets/sets/base/images/*.png` | Card art — one PNG per card, named to match `image_filename` in cards.json |

---

## Managing cards

### Create a card
```bash
./scripts/create-card.sh [--set-id <id>] "<name>" "<description>" "key=value,key=value"
```
- `--set-id` defaults to `base`
- `image_filename` is auto-derived from the name: lowercased, spaces→hyphens, non-alphanumeric chars stripped, `.png` appended
- After running, place the matching PNG in `assets/sets/base/images/`

### Delete a card
```bash
./scripts/delete-card.sh [--set-id <id>] "<name>"
```
Removes the card from `cards.json` AND deletes its image file. Name match is case-insensitive.

### Edit an existing card (delete + recreate)
```bash
./scripts/delete-card.sh "<name>"
./scripts/create-card.sh "<name>" "<new description>" "key=value,key=value"
# Replace the image in assets/sets/base/images/ if the art changed
```

### cards.json entry shape
```json
{
  "name": "Card Name",
  "description": "Flavor or mechanical text.",
  "image_filename": "card-name.png",
  "attributes": {
    "rarity": "common",
    "cost": "3"
  }
}
```
All attribute keys and their types must match the `attributes` map on the `tcg-sandbox_game` resource in `main.tf`.

---

## Game resource schema (main.tf)

### Top-level fields
- `name` — display name shown on tcg-sandbox.com
- `description` — short tagline for the game
- `banner_image_path` — relative path to the banner PNG
- `banner_vertical_alignment` — number controlling vertical crop offset of the banner
- `attributes` — **map of attribute name → type** (`"string"`, `"number"`, or `"boolean"`). Every card must supply a value for each attribute. **This is game-specific and must be designed collaboratively with the user** — it should reflect what mechanically distinguishes cards in this game (e.g. `health`, `power`, `rarity`, `cost`, `type`, `is_legendary`).

### `options` block
- `card_display_mode`: `"managed"` shows name + attribute values; `"imageonly"` shows art only
- `card_display_context`: `"everywhere"` or `"ingameonly"`

### `rules` block
- `content`: markdown string — loaded from `assets/rules.md`

### `game_play_data` block
- `player_count`: number of players (1–4)
- `slots`: list of GridSlot objects defining the play area (see below)

---

## Game board design (GridSlots)

> **IMPORTANT:** tcg-sandbox automatically manages each player's hand and deck. Do NOT define slots for those. Slots are only for the shared play area: battlefield zones, discard piles, resource zones, counter areas, and other play-area elements.

The game board is a **6×6 grid**. Each slot is a rectangular region defined by its top-left corner and its dimensions.

### GridSlot fields

| Field | Type | Description |
|---|---|---|
| `row` | number | Top-left row (0-based, 0 = top) |
| `column` | number | Top-left column (0-based, 0 = left) |
| `height` | number | Number of rows the slot spans |
| `width` | number | Number of columns the slot spans |
| `type` | string | `"cards"` or `"counters"` |
| `visibility` | string | `"public"` (all players see it) or `"private"` (owner only) |
| `max_count` | number | Max items the slot can hold |
| `player_owner` | number | 1-based player number who owns this slot; omit for shared/neutral zones |

### Example — 2-player battlefield (rows 0–2 for P1, rows 3–5 for P2):
```hcl
slots = [
  { row = 0, column = 0, height = 3, width = 6, type = "cards", visibility = "public", max_count = 10, player_owner = 1 },
  { row = 3, column = 0, height = 3, width = 6, type = "cards", visibility = "public", max_count = 10, player_owner = 2 },
]
```

When designing the board, draw out an ASCII sketch of the 6×6 grid and confirm slot placement with the user before writing to `main.tf`.

---

## Multi-phase game design workflow

When a user is starting from scratch or wants to build out their game, guide them through these phases in order. Complete and confirm each phase before moving to the next.

### Phase 1 — Game identity & rules
Ask about:
- Theme and setting
- Win and loss conditions
- Card types and how they differ
- Deck construction rules
- Turn structure and phases
- Key mechanics (combat, resources, status effects, etc.)

Collaboratively write `assets/rules.md` section by section. Confirm before moving on.

### Phase 2 — Card attributes & display options
- Explain that `attributes` in `main.tf` is game-specific — it defines the data model for every card
- Ask what makes cards mechanically different from each other in this game
- Suggest attribute names and types based on their description (e.g. for a creature battler: `"health": "number"`, `"power": "number"`, `"rarity": "string"`, `"creature_type": "string"`)
- Get user confirmation, then update the `attributes` block and `options` block in `main.tf`
- Confirm before moving on

### Phase 3 — Board design
- Remind the user: hand and deck are managed automatically — only define play area zones
- Ask what zones the board needs (battlefield rows, discard pile, resource zone, shared zones, etc.)
- Ask player count
- Sketch the board layout in ASCII on the 6×6 grid, then translate to GridSlot definitions
- Update `game_play_data` in `main.tf` once confirmed

### Phase 4 — Card creation

For each card, prefer the **image-first flow**:

1. Ask if the user has card art or wants to create some first
2. If no image yet — suggest generating art with ChatGPT's image generation, Midjourney, DALL-E, or similar tools, then dropping the PNG into `assets/sets/base/images/`
3. **When an image path is provided — use the Read tool to open and view the image.** Interpret the visual art to infer:
   - Card name (from the subject or mood of the image)
   - Description / flavor text (from the scene, character, or atmosphere)
   - Attribute values (infer rarity, power, cost, type, etc. from the visual weight and feel of the art)
4. Present the inferred card data for user review and tweaks
5. Run `create-card.sh` with the confirmed values

**Text-first fallback** (when user doesn't want to create an image first):
1. Ask for a natural-language description of the card
2. Derive name, description, and attributes from that description
3. Create a image generation prompt for the user which gives an image generation AI enough information to generate a high-quality card image that fairly represents the natural language description for the card. Store the prompt in a temporary file "{card-name}-prompt.txt" at the same location that the image file should be stored in.
4. Run `create-card.sh`, inform user of the prompt file from step 3 and tell them to replace the text file with the generated image file later.

Repeat for each card until the set is complete.

### Phase 5 — Lore
- Ask about the game world: key characters, factions, historical events, creation myths, conflicts
- Write each story as a `.md` file in `assets/lore/` — the filename (underscores→spaces, title case) becomes the post title on tcg-sandbox.com
- Remove `placeholder-story.md` once real lore is in place

### Deployment
Once all content is ready:
```bash
terraform init
terraform apply
```
Review the plan and confirm to publish the game to tcg-sandbox.com.
