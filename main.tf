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

resource "tcg-sandbox_game" "placeholder" {
  name        = "Placeholder Name"
  description = "Your game description here"

  banner_image_path         = "${path.root}/assets/banner.png"
  banner_vertical_alignment = 12

  attributes = {
    # Examples: Add your own!
    rarity = "string",
    cost   = "number"
  }

  game_play_data {
    player_count = 2
    # Example board layout: replace this with your own design!
    # It's possible to design this in the web UI and then derive
    # the content via a "data source" pointing at your game.
    slots = [
      {
        id           = 1
        row          = 0
        column       = 0
        width        = 6
        height       = 3
        type         = "card"
        max_count    = 10
        visibility   = "public"
        player_owner = 1
      },
      {
        id           = 2
        row          = 3
        column       = 0
        width        = 6
        height       = 3
        type         = "cards"
        max_count    = 10
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

  game_id         = tcg-sandbox_game.placeholder.id
  set_id          = "base"
  name            = each.value.name
  description     = each.value.description
  card_image_path = "${path.root}/assets/sets/base/images/${each.value.image_filename}"
  attributes      = each.value.attributes
}

# Lore Posts - One for each markdown file in assets/lore

resource "tcg-sandbox_lore_post" "posts" {
  for_each = fileset("${path.root}/assets/lore", "*.md")

  game_id = tcg-sandbox_game.placeholder.id

  # Replace '-' & '_' -> empty space and capitalize each word.
  # E.g.: 'placeholder_story.md' -> "Placeholder Story"
  title   = join(" ", [for word in split(" ", replace(replace(trimsuffix(each.value, ".md"), "-", " "), "_", " ")) : title(word)])
  content = file("${path.root}/assets/lore/${each.value}")
}

# Outputs - Information that will show after terraform interactions

output "banner_image_url" {
  value       = tcg-sandbox_game.placeholder.banner_image_public_url
  description = "Public URL for the hosted banner image."
}

output "base_set_attributes" {
  value       = tcg-sandbox_game.placeholder.attributes
  description = "Immutable attributes that must be provided by all cards"
}
