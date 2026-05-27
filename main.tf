terraform {
  required_providers {
    tcg-sandbox = {
      source  = "tcgsandbox/tcg-sandbox"
      version = "~>0.0.3"
    }
  }
}

provider "tcg-sandbox" {
  host    = "https://api.tcg-sandbox.com"
  api_key = var.api_key
}

# Game Setup

resource "tcg-sandbox_game" "terraformers" {
  name        = "Terraformers TCG"
  description = "Two rival gods sculpt a shared world. Claim its lands, command its creatures, and reshape the planet to your will."

  banner_image_path         = "${path.root}/assets/banner.png"
  banner_vertical_alignment = 12

  attributes = {
    card_type = "string" # "land" | "spell" | "unit"
    rarity    = "string" # "common" | "rare" | "legendary"
    cost      = "number" # Essence cost. Lands are always 0.
    biome     = "string" # Biome for lands (e.g. "forest"); "none" for non-lands.
    might     = "number" # Unit attack value. 0 for non-units.
    resolve   = "number" # Unit HP. 0 for non-units.
  }

  game_play_data {
    player_count = 2
    # 6x6 grid layout:
    #   rows 0-1: P1 Domain (lands, cols 0-3) + P1 Divinity & Essence counters (cols 4-5)
    #   row  2:   P1 Battlefield (units, full width)
    #   row  3:   P2 Battlefield (units, full width)
    #   rows 4-5: P2 Domain (lands, cols 0-3) + P2 Divinity & Essence counters (cols 4-5)
    slots = [
      # P1 Domain — 4 wide × 2 tall = 8 cells for lands, capped at 7 (Dominion threshold).
      {
        id           = 1
        row          = 0
        column       = 0
        width        = 4
        height       = 2
        type         = "cards"
        max_count    = 7
        visibility   = "public"
        player_owner = 1
      },
      # P1 Divinity counter — life total, starts at 20.
      {
        id           = 2
        row          = 0
        column       = 4
        width        = 2
        height       = 1
        type         = "counters"
        max_count    = 1
        visibility   = "public"
        player_owner = 1
      },
      # P1 Essence counter — resource pool.
      {
        id           = 3
        row          = 1
        column       = 4
        width        = 2
        height       = 1
        type         = "counters"
        max_count    = 1
        visibility   = "public"
        player_owner = 1
      },
      # P1 Battlefield — units in play.
      {
        id           = 4
        row          = 2
        column       = 0
        width        = 6
        height       = 1
        type         = "cards"
        max_count    = 6
        visibility   = "public"
        player_owner = 1
      },
      # P2 Battlefield.
      {
        id           = 5
        row          = 3
        column       = 0
        width        = 6
        height       = 1
        type         = "cards"
        max_count    = 6
        visibility   = "public"
        player_owner = 2
      },
      # P2 Domain.
      {
        id           = 6
        row          = 4
        column       = 0
        width        = 4
        height       = 2
        type         = "cards"
        max_count    = 7
        visibility   = "public"
        player_owner = 2
      },
      # P2 Divinity counter.
      {
        id           = 7
        row          = 4
        column       = 4
        width        = 2
        height       = 1
        type         = "counters"
        max_count    = 1
        visibility   = "public"
        player_owner = 2
      },
      # P2 Essence counter.
      {
        id           = 8
        row          = 5
        column       = 4
        width        = 2
        height       = 1
        type         = "counters"
        max_count    = 1
        visibility   = "public"
        player_owner = 2
      },
    ]
  }

  options {
    card_display_mode    = "managed"
    card_display_context = "everywhere"
  }

  rules {
    content = file("${path.root}/assets/rules.md")
  }
}

# Base Set Cards - One for each entry in the set's cards.json file.
# Reminder: add images for these cards at `assets/sets/base/images/`.

resource "tcg-sandbox_card" "cards" {
  for_each = { for card in jsondecode(file("${path.root}/assets/sets/base/cards.json")) : card.name => card }

  game_id         = tcg-sandbox_game.terraformers.id
  set_id          = "base"
  name            = each.value.name
  description     = each.value.description
  card_image_path = "${path.root}/assets/sets/base/images/${each.value.image_filename}"
  attributes      = each.value.attributes
}

# Lore Posts - One for each markdown file in assets/lore

resource "tcg-sandbox_lore_post" "posts" {
  for_each = fileset("${path.root}/assets/lore", "*.md")

  game_id = tcg-sandbox_game.terraformers.id

  # Replace '-' & '_' -> empty space and capitalize each word.
  # E.g.: 'placeholder_story.md' -> "Placeholder Story"
  title   = join(" ", [for word in split(" ", replace(replace(trimsuffix(each.value, ".md"), "-", " "), "_", " ")) : title(word)])
  content = file("${path.root}/assets/lore/${each.value}")
}

# Outputs - Information that will show after terraform interactions

output "banner_image_url" {
  value       = tcg-sandbox_game.terraformers.banner_image_public_url
  description = "Public URL for the hosted banner image."
}

output "base_set_attributes" {
  value       = tcg-sandbox_game.terraformers.attributes
  description = "Immutable attributes that must be provided by all cards"
}
