# Brainstorm: Multi-Stage Level Design

**Author**: Designer Agent
**Date**: 2026-04-16
**Scope**: Design 3 distinct stages (Dark Forest / Lava Cavern / Demon Castle) with unique enemy compositions, environmental effects, and boss encounters.

---

## Problem Statement

Current game has a single flat 3000x3000 arena with continuous enemy spawning. Competitive analysis identifies "no stage variety" as a HIGH gap. All genre leaders (VS, Brotato, HoloCure) use multiple stages with different enemy pools and visual themes. The stage-system spec (`stage-system.md`) defines wave structure within a run, but does not address multi-stage progression across different maps.

**Goal**: Design 3 stages, each with unique wave compositions, at least one new enemy type, environmental effects, and escalating difficulty. Stages unlock sequentially (Stage 1 clear unlocks Stage 2, etc.).

---

## Brainstorm Proposals

### Proposal 1: "Linear Campaign" -- 3 Sequential Stages

Stage 1 (Forest) -> Stage 2 (Cavern) -> Stage 3 (Castle). Each stage is a full 5-wave run. Player carries weapons/levels between stages. Total play time: ~15 minutes for a full run.

**Pros**: Full progression arc; player grows across stages; satisfying campaign feel.
**Cons**: 15-minute runs are long; dying on Stage 3 after 10 minutes is frustrating; weapon balance across 15 minutes is untested.

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 4 | Scene transitions, carry-over state, 3 arena maps |
| Balance difficulty | 5 | 15-minute XP economy, weapon scaling across stages |
| Player understanding | 2 | "Clear stage, move to next" is intuitive |

---

### Proposal 2: "Stage Select" -- 3 Independent Stages

Each stage is a standalone 5-minute run. Player selects stage from a menu. Each stage has its own difficulty tuning and unique enemies. No carry-over between stages.

**Pros**: Short 5-minute runs (matches current H5 design); each stage is a complete experience; easier to balance independently.
**Cons**: No progression arc; less sense of journey; unlocks feel less rewarding.

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 3 | 3 arena scenes, stage select screen |
| Balance difficulty | 2 | Each stage is self-contained |
| Player understanding | 2 | "Pick a stage, play 5 minutes" |

---

### Proposal 3: "Campaign with Carry-Over" -- Hybrid

3 stages in sequence. Stage 1 is 3 waves (tutorial), Stage 2 is 4 waves, Stage 3 is 5 waves with boss. Player keeps weapons and levels between stages. Total ~10 minutes. Each stage has inter-stage shop/refit screen.

**Pros**: Good pacing (10 minutes is sweet spot); tutorial in Stage 1; escalation to boss in Stage 3; inter-stage break reduces fatigue.
**Cons**: Inter-stage shop adds UI complexity; weapon balance across 10 minutes needs care.

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 4 | Scene transitions + inter-stage UI + carry-over |
| Balance difficulty | 4 | 10-minute economy |
| Player understanding | 3 | "Stage clear -> brief rest -> next stage" |

---

### Proposal 4: "Endless Stages" -- Procedural Progression

Stages are generated procedurally. Each "stage" is a 60-second arena with random enemy composition. After clearing, transition to next stage with harder enemies. No fixed map -- arena layouts are randomly assembled.

**Pros**: Infinite replayability; no fixed content limits.
**Cons**: Procedural generation is technically complex; no hand-crafted experience; quality unpredictable; hard to balance.

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 5 | Procedural generation system |
| Balance difficulty | 5 | Cannot tune individual stages |
| Player understanding | 3 | "What comes next?" unpredictability |

---

### Proposal 5: "Branching Paths"

After Stage 1, player chooses between 2 paths (Lava Cavern or Frozen Tundra). Each path leads to a different Stage 3 boss. 3 stages total but 4 possible routes.

**Pros**: Replayability through choice; encourages multiple runs.
**Cons**: Doubles content requirement (2 different Stage 2 + 2 different Stage 3); complex unlock tracking.

**Feasibility**:
| Dimension | Score (1-5) | Notes |
|---|---|---|
| Technical cost | 5 | Branching logic + 4 unique stages |
| Balance difficulty | 4 | 4 paths to balance |
| Player understanding | 3 | "Choose your path" is clear |

---

## Convergence: Selected Proposal

**Selected: Proposal 2 (Stage Select) as primary, with Proposal 3 (Campaign) as future evolution**

Rationale:
1. Stage Select matches the current 5-minute run structure perfectly -- no XP economy redesign needed
2. Each stage is self-contained and independently balanceable
3. Lower technical risk -- 3 separate arena scenes + a stage select screen
4. Future evolution to Campaign mode (Proposal 3) is a natural extension once the base 3 stages work
5. Unlocks provide meta-progression: Stage 1 always available, Stage 2 unlocks after clearing Stage 1 on Normal, Stage 3 unlocks after clearing Stage 2 on Normal

**Stage themes**:
1. **Dark Forest (幽暗森林)** -- Tutorial stage, basic enemies only, gentle difficulty curve
2. **Lava Cavern (熔岩洞窟)** -- New enemy type (Fire Slime), environmental lava zones
3. **Demon Castle (魔王城)** -- Multi-phase Boss, all enemy types, hardest composition

**Each stage runs the existing 5-wave structure** from `stage-system.md`, but with stage-specific wave definitions, enemy pools, and environmental modifiers.
