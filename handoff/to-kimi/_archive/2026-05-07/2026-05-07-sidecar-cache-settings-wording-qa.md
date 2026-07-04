# Kimi QA Directive - Sidecar Cache Settings Wording

Status: APPROVED / ARCHIVED

## Purpose

Verify the small Settings > Storage > Scenario Sidecar Cache wording polish in Codex commit `2ba77a8 Polish sidecar cache settings wording`.

This is a focused UI wording / regression pass. The expected product behavior is unchanged.

## Target Commit

```text
2ba77a8 Polish sidecar cache settings wording
```

## Expected Scope

The target commit should modify only:

```text
src/App.jsx
```

Expected intent:

- Replace leftover English status text in the Scenario Sidecar Cache settings card.
- Keep sidecar/cache safety wording intact.
- Keep commands, copy behavior, sidecar root, and `.scen` not modified guidance unchanged.

## Boundaries

- Do not edit files.
- Do not commit.
- Do not create, delete, move, or retag Git tags.
- Do not edit GitHub Releases.
- Do not prune or delete sidecars.
- Do not run broad scenario extraction.
- Treat `_archive/` as evidence only, not active instruction.

## Required Commands

```powershell
git status --short --branch
git show --stat --oneline 2ba77a8
npm run lint
npm run build
npm run smoke:ai-adapter
```

If `build` or `smoke:ai-adapter` hits sandbox `spawn EPERM`, report it as environment and rerun with approved permissions if available.

## Static Checkpoints

1. Target commit changes only `src/App.jsx`.
2. Loading message is Korean: `sidecar 인덱스를 확인하는 중입니다.`
3. Success timestamp message is Korean: `인덱스 생성 시각: ...`.
4. Unknown timestamp fallback is Korean: `알 수 없음`.
5. Error message is Korean: `sidecar 인덱스를 읽지 못했습니다: ...`.
6. Indexed total label is Korean: `N개 시나리오 인덱싱됨`.
7. Pending label is Korean: `인덱스 확인 중`.
8. Count labels are Korean:
   - `내부 컨텍스트 준비`
   - `메타데이터만`
   - `디코더 실패`
9. Sidecar root hint remains `%USERPROFILE%\.codex\cmo-scenario-sidecars`.
10. `CMO_SCENARIO_SIDECAR_ROOT` override hint remains.
11. `.scen` not modified wording remains.
12. Command rows remain unchanged:
   - `npm run audit:scenario-sidecars`
   - `npm run prune:scenario-sidecars`
   - `npm run prune:scenario-sidecars -- --yes`
   - `npm run move:scenario-sidecars`
   - `npm run move:scenario-sidecars -- --move --yes`
13. Manual prompt-copy fallback remains present.
14. Lua apply remains gated by `aiParsedResponse.isPasteReady === true`.
15. No raw credential strings are introduced.

## Expected Baseline

- Main JS should remain under `400 kB`; Codex observed `366.67 kB`.
- Main CSS should remain `58.27 kB`, under `60 kB`.
- `aiContextPruning` should remain `8.56 kB`, under `9 kB`.
- `npm run lint`: PASS.
- `npm run build`: PASS.
- `npm run smoke:ai-adapter`: PASS, no raw `Bearer` / `sk-` leakage.

## Expected Final Verdict

```text
APPROVED - sidecar cache settings wording holds.
```
