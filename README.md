# Claude skills

My personal skills for Claude Code. This folder is `~/.claude/skills`; Claude Code loads every skill in it.

| Skill | What it does |
|---|---|
| [whimsical-frontend](whimsical-frontend/SKILL.md) | Animation, style and CSS techniques from Josh W. Comeau's tutorials: springy hovers, pushable buttons, sparkles, layered shadows, gradients, frosted glass, reduced motion and more. |
| [pr-mechanism-page](pr-mechanism-page/SKILL.md) | A visual page that explains the mechanism a PR (or a stack of PRs) proposes, compares it with published references, and backs it with local simulations on synthetic data. Includes a reference library and sandbox scripts. |

## Install

```sh
git clone https://github.com/Sr-santi/claude-skills.git ~/.claude/skills
```

Or copy one skill folder into `~/.claude/skills/`.

## Credits

`whimsical-frontend` is an unofficial study guide to the work of [Josh W. Comeau](https://www.joshwcomeau.com/). The ideas and values are his; each section links to the article it comes from. Read the originals, and see his courses [CSS for JavaScript Developers](https://css-for-js.dev/) and [Whimsical Animations](https://whimsy.joshwcomeau.com/). Not affiliated with or endorsed by him.

Only skills whitelisted in `.gitignore` are published; other skills in this folder stay local.
