# Terraformers TCG Rules

Two rival gods sculpt a shared world. Claim its lands, command its creatures, and reshape the planet to your will.

---

# Objective

Win in one of two ways:

- **Dominion** — control **7 lands** at the end of your turn.
- **Annihilation** — reduce the opposing god's **Divinity** to 0.

Each player starts at **20 Divinity**.

---

# Components

- A shared deck zone, hand, and graveyard for each player (managed automatically).
- A shared world board with two **Domains** — one per god — where lands are played.
- A central **Battlefield** where units fight and spells resolve.
- Counter slots for each god's **Divinity** and current **Essence** pool.

---

# Card Types

- **Lands** — the heart of the game. Played into your Domain. Each land produces **Essence** under its own conditions (see *Land Biomes* below). Lands can be **razed** by enemy units or spells.
- **Units** — creatures with **Might** (attack) and **Resolve** (HP). They cost Essence to summon and live on the Battlefield. Units may attack enemy lands or the opposing god.
- **Spells** — one-shot effects. Cost Essence, resolve immediately, and go to the graveyard.

---

# Deck Construction

- **30 cards** per deck.
- At least **15 of those cards must be lands**.
- No more than **3 copies** of any single non-basic-land card.
  - There is no limit on basic land cards (non-unique lands).

---

# Setup

1. Each player shuffles their deck and draws **5 cards**.
2. Set each god's Divinity counter to **20**.
3. Set each god's Essence counter to **0**.
4. Determine first player however you'd like (coin flip, dice roll, etc.).
5. The first player **skips their first Tribute and Draw step** to compensate for going first.

---

# Turn Structure

A turn has six steps, taken in order.

## 1. Dawn

Ready all your tapped lands and exhausted units.

## 2. Draw

Draw one card.

## 3. Tribute

Each of your lands generates Essence based on its biome. Add the total to your Essence pool. Unspent Essence carries over between turns.

## 4. Shape

You may:
- Play up to **one land** into your Domain (free; lands have no Essence cost).
- Cast any number of **spells** and **summon units**, paying their Essence cost.

## 5. Strike

Each of your ready units may either:
- **Attack an enemy land** — the land is razed and sent to the graveyard. The defending god may sacrifice a unit to block; the blocker and attacker exchange Might as damage to each other's Resolve, and any unit reduced to 0 Resolve is destroyed.
- **Attack the opposing god directly** — deal Might in Divinity damage. The defender may block as above.

A unit that attacks becomes exhausted until your next Dawn.

## 6. Dusk

End your turn. Your opponent begins theirs.

---

# Mechanics

## Land Biomes

Lands all draw from a single shared **Essence** pool, but each biome generates Essence under different conditions during the Tribute step:

| Biome | How it generates Essence |
|---|---|
| **Tundra** | Always produces **1**. The most reliable land. |
| **Forest** | Produces **1** for every Forest you control (including itself). Stacks. |
| **Jungle** | Produces **0** if you have no units on the Battlefield. Produces **2** if you control at least one unit. |
| **Mountain** | Produces **2** the turn you cast any spell. Otherwise, produces 0. |
| **Ocean** | Produces **2** the turn an opponent casts any spell. Otherwise, produces 0. |
| **Desert** | Produces **2**, but only on every *other* turn. Tap it after producing; it skips its next Tribute. |
| **Beach** | Produces **2** if it is the only land in your domain. Otherwise, produces 1 as long as there is an ocean in your domain. |
| **River** | Produces **1** for each adjacent Forest, Ocean, or Beach in your Domain. |

Unique and legendary lands have their own one-of-a-kind Tribute rules — read each card carefully.

## Razing Lands

When a land is razed:
- It goes to the graveyard.
- Any continuous effect it provided ends.
- Its slot is freed; you may play another land into it on a future turn.

## Combat & Damage

Combat is unit-vs-unit or unit-vs-god / unit-vs-land:
- **Might** = damage dealt.
- **Resolve** = damage absorbed before destruction. Damage persists across turns until the unit heals or is destroyed.
- A unit may only attack once per turn.

## Resources

There is one shared resource per player: **Essence**. It accumulates over the game and is spent to summon units and cast spells. There is no upkeep cost — Essence is yours until you spend it.

## Winning & Losing

The game ends the moment **either** win condition is met. If both conditions are met simultaneously (e.g. a final attack razes your 7th land while killing the opposing god), the **active player** wins.
