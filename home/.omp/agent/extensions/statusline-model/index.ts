/**
 * statusline-model
 *
 * The built-in `model` status-line segment renders `model.name || model.id`,
 * so it never shows the provider. Extension statuses (`ui.setStatus`) are
 * ANSI-stripped before rendering, so a hand-built label cannot be colored
 * either.
 *
 * Instead, this rewrites the live model's display name to `provider/model-id`.
 * The native segment then paints it with the `statusLineModel` theme color and
 * appends the thinking level (colored per level through the `thinking.*`
 * symbol overrides in the theme).
 *
 * Config side (~/.omp/agent/config.yml):
 *   statusLine.leftSegments: [model, ...]
 *   statusLine.segmentOptions.model.showThinkingLevel: true
 *   statusLine.compactThinkingLevel: false   # level after the name, not instead of the icon
 */

import type { ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

const POLL_MS = 1000;

// The segment wraps everything it renders (name, separator and thinking level)
// in one `statusLineModel` color, so a green token would also tint the dot in
// `name · level`. The theme therefore leaves `statusLineModel` unset (default
// foreground, matching every other separator) and the green is embedded here,
// around the name only. It never reaches the system prompt: that path formats
// `provider/id` itself and ignores `name`.
const MODEL_FG = "\u001b[38;2;135;154;57m"; // #879A39 — theme var `greenBright`
const RESET_FG = "\u001b[39m";

type MutableModel = { provider?: string; id?: string; name?: string };

/** `/model` emits no extension event, so the live model is polled. */
function applyName(ctx: ExtensionContext): boolean {
  const model = (ctx.models?.current?.() ?? ctx.model) as MutableModel | undefined;
  if (!model?.provider || !model.id) return false;
  const wanted = `${MODEL_FG}${model.provider}/${model.id}${RESET_FG}`;
  if (model.name === wanted) return false;
  try {
    model.name = wanted;
  } catch {
    return false;
  }
  return model.name === wanted;
}

export default function (pi: ExtensionAPI): void {
  const sync = (ctx: ExtensionContext): void => {
    if (!applyName(ctx) || !ctx.hasUI) return;
    // Nothing here schedules a paint; clearing an unused widget key is a no-op
    // that reaches ui.requestRender(), so the new label shows immediately.
    ctx.ui.setWidget?.("statusline-model-repaint", undefined);
  };

  pi.on("session_start", async (_event, ctx) => {
    sync(ctx);
    const timer = ctx.setInterval(() => sync(ctx), POLL_MS);
    pi.on("session_shutdown", () => ctx.clearTimer(timer));
  });

  for (const event of ["turn_start", "turn_end", "session_switch", "session_branch"] as const) {
    pi.on(event, async (_e: unknown, ctx: ExtensionContext) => sync(ctx));
  }
}
