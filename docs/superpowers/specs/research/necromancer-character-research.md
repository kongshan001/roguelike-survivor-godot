# Necromancer Character Research

**Date**: 2026-04-18
**Round**: R33
**Topic**: 4th character design -- kill-scaling archetype

---

## 1. Genre Kill-Scaling Mechanics Analysis

| Game | Kill-Scaling Mechanic | Scaling Rate | Cap | Trigger | Assessment |
|------|----------------------|-------------|-----|---------|------------|
| Vampire Survivors | Some characters have bonus XP/level rate | +10-30% XP rate | None | Passive | INDIRECT -- scales level, not damage |
| Brotato | Some chars gain stats per wave survived | +1-3% per wave | Soft (game ends) | End of wave | INDIRECT -- scales with time, not kills |
| HoloCure | Stamp cards scale with viewer count | +1% per 100 viewers | +50% | Passive (观众) | DIRECT -- audience count parallels kill count |
| Magic Survival | None | N/A | N/A | N/A | -- |

**Key insight**: No major survivor game has a character whose weapon damage directly scales with kill count. This is an untapped design space. The closest analog is HoloCure's viewer count scaling, but that is a separate metric, not kill-based.

## 2. Risk Analysis: Kill-Scaling in Endless Mode

**Problem**: In Endless mode, kill counts can exceed 1000-2000. If scaling is uncapped, the character becomes exponentially stronger than others.

**Quantitative analysis** (Normal difficulty, assumed 4 kills/second in late game):

| Elapsed Time | Estimated Kills | Uncapped +2%/100 | Capped +20% |
|-------------|----------------|-------------------|-------------|
| 1:00 | ~50 | +1% | +1% |
| 3:00 | ~250 | +5% | +5% |
| 5:00 | ~500 | +10% | +10% |
| 10:00 | ~1200 | +24% | +20% (cap) |
| 15:00 | ~2000 | +40% | +20% (cap) |
| 20:00 | ~3000 | +60% | +20% (cap) |

**Conclusion**: A hard cap is essential. +20% cap means the Necromancer matches Mage's flat bonus at best, never exceeds it in raw DPS (because Necromancer lacks the multiplicative 1.20x character passive).

## 3. Active Skill Kill-Scaling Comparison

| Game | Skill Scaling Type | Source | Cap | Our Reference |
|------|-------------------|--------|-----|---------------|
| HoloCure | Some skills scale with HP missing | Current HP | N/A | Not applicable (different axis) |
| Brotato | Some weapons scale with enemies nearby | Proximity | Soft | Interesting but complex |
| VS | No kill-scaling skills | N/A | N/A | Baseline (no precedent) |

**Novel approach**: Death Pulse scaling with total kills is unique to our design. The skill starts weaker than comparable skills (8.0 vs Mage 15.0) and scales to 38.0 at 600+ kills. This creates a clear "investment and payoff" curve.

---

*Research completed R33*
