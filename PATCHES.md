# weblapp's GetX maintenance line

This repository is weblapp's fork of [jonataslaw/getx](https://github.com/jonataslaw/getx).
GetX is the core of our apps, and its only maintainer has asked the community for help
([#3482](https://github.com/jonataslaw/getx/issues/3482)). This fork is a maintenance line,
not a rival project: we keep the version we ship working, and we offer our fixes back.
GetX is MIT-licensed; its license and its authors' credit stay as they are.

## Branches

| Branch | Job | Who changes it |
| --- | --- | --- |
| `master` | A mirror of upstream `master` (the 5.0 line), fast-forwarded daily by `weblapp-sync-upstream` | the sync only |
| `release/4.7.3` | `get` 4.7.3 exactly as published on pub.dev (sha256 `5ed34a7925b85336…`), frozen | nobody |
| `weblapp/4.7.x` | Our line: 4.7.3 plus only the fixes we needed, each listed below; released as tags `v4.7.3-wl.N` | weblapp, one reviewed change at a time |
| `fix/<topic>` | One change, from our line or from upstream `master` (for a pull request upstream) | weblapp |

Our apps take GetX from a **tag** of `weblapp/4.7.x`, never from a moving branch.

## How a change enters `weblapp/4.7.x`

1. **The need.** The bug is shown to reach one of our apps: reproduced in the app or in a test on 4.7.3.
   A fix for something we never hit waits.
2. **The smallest port.** Only the lines the fix needs, adapted to 4.7.3. Upstream `master` is the
   5.0 line and differs from 4.7.3 in about a hundred files, so nothing is cherry-picked as is. A
   change taken from an upstream pull request credits its author (`Co-authored-by:`).
3. **A test** that fails before the change and passes after it.
4. **The gates.** `weblapp-test` green on this line; the app's own test suite and a device check;
   then a new tag, and the app's pin moved in its own commit.
5. **A row in the ledger below**, in the same change.

When the bug also exists on 5.0, the fix is ported to a `fix/<topic>` branch from upstream `master`
and offered to `jonataslaw/getx` as a pull request, with its test.

## The ledger — every way `weblapp/4.7.x` differs from the published 4.7.3

| # | Change | Why we needed it | Test | Source | Upstream |
| --- | --- | --- | --- | --- | --- |
| — | none yet: `lib/` and `test/` equal `release/4.7.3` | | | | |

Infrastructure only, not code: this file, `.github/workflows/weblapp-*.yml`,
`.github/scripts/check-known-failures.sh`, `.github/known-failures.txt`.

## Known test failures at the base

GetX's own suite at 4.7.3, run on Flutter 3.47.8 (Dart 3.13.7): 144 pass, 4 fail. They are listed
in `.github/known-failures.txt`. `weblapp-test` fails on any failure not in that list, and says when a
listed one passes again, so the list only shrinks.

| # | Test | Measured |
| --- | --- | --- |
| K-1 | `test/navigation/snackbar_test.dart` — test snackbar dismissible | `Expected: <false>, Actual: <true>` (line 151) |
| K-2 | `test/navigation/snackbar_test.dart` — test snackbar onTap | widgets-library exception |
| K-3 | `test/navigation/snackbar_test.dart` — Get test actions and icon | |
| K-4 | `test/navigation/routes_test.dart` — Back swipe dismiss interrupted by route push | `Expected: Offset(400.0, 0.0), Actual: Offset(35.2, 15.0)` |

Not investigated yet. K-4 is a back-swipe case on route pushes, an area our apps use; it is the
first to look at if a back-swipe bug reaches us.
