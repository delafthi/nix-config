import type { Plugin } from "@opencode-ai/plugin";

const NUDGE_MS = 120000;
const NUDGE_COOLDOWN_MS = 120000;
const STUCK_MS = 240000;
const STUCK_COOLDOWN_MS = 300000;
const MAX_SESSIONS = 100;

const NUDGE_MSG = (minutes: number): string =>
  `Progress update: ${minutes}m since your last progress/update. Start your reply with a one-line status: current problem -> next step.`;

const STUCK_MSG = (minutes: number): string =>
  `Are you stuck? ${minutes}m in a loop without progress. Evaluate: have you made real progress? If not, stop and ask the user for help. State the exact problem you are stuck on, clearly, and ask how they want you to proceed. Ask directly in your reply, not via the question tool.`;

type Todo = { content: string; status: string; priority: string };

type SessionState = {
  lastProgressAt: number;
  lastToolAt: number;
  lastNudgeAt: number;
  lastStuckAt: number;
  lastTodoSnapshot: string | undefined;
  suppressNudge: boolean;
};

const sessions = new Map<string, SessionState>();

function getState(sessionID: string): SessionState {
  if (sessions.size >= MAX_SESSIONS && !sessions.has(sessionID)) {
    let oldestKey: string | undefined;
    let oldestAt = Infinity;
    for (const [id, state] of sessions) {
      if (state.lastProgressAt < oldestAt) {
        oldestAt = state.lastProgressAt;
        oldestKey = id;
      }
    }
    if (oldestKey !== undefined) sessions.delete(oldestKey);
  }
  let state = sessions.get(sessionID);
  if (!state) {
    const now = Date.now();
    state = {
      lastProgressAt: now,
      lastToolAt: now,
      lastNudgeAt: 0,
      lastStuckAt: 0,
      lastTodoSnapshot: undefined,
      suppressNudge: false,
    };
    sessions.set(sessionID, state);
  }
  return state;
}

function markProgress(state: SessionState): void {
  state.lastProgressAt = Date.now();
  state.suppressNudge = false;
}

function minutesSince(ms: number): number {
  return Math.floor(ms / 60000);
}

export const ControlFreak: Plugin = async () => {
  return {
    event: async ({ event }) => {
      if (event.type !== "todo.updated") return;
      const { sessionID, todos } = event.properties;
      if (!sessionID) return;
      const state = getState(sessionID);
      const snapshot = JSON.stringify(
        todos.map((t) => JSON.stringify(t)).sort(),
      );
      if (snapshot !== state.lastTodoSnapshot) {
        markProgress(state);
        state.lastTodoSnapshot = snapshot;
      }
    },

    "chat.message": async (input, output) => {
      if (!input.sessionID) return;
      if (output.message.role !== "user") return;
      markProgress(getState(input.sessionID));
    },

    "tool.execute.after": async (input) => {
      if (!input.sessionID) return;
      getState(input.sessionID).lastToolAt = Date.now();
    },

    "experimental.chat.system.transform": async (input, output) => {
      if (!input.sessionID) return;
      const state = getState(input.sessionID);
      const now = Date.now();
      const sinceActivity =
        now - Math.max(state.lastProgressAt, state.lastToolAt);
      const minutes = minutesSince(sinceActivity);

      if (
        sinceActivity >= STUCK_MS &&
        (state.lastStuckAt === 0 ||
          now - state.lastStuckAt >= STUCK_COOLDOWN_MS)
      ) {
        output.system.push(STUCK_MSG(minutes));
        state.lastStuckAt = now;
        state.lastNudgeAt = now;
        state.suppressNudge = true;
        return;
      }

      if (state.suppressNudge) return;

      if (
        sinceActivity >= NUDGE_MS &&
        now - state.lastNudgeAt >= NUDGE_COOLDOWN_MS
      ) {
        output.system.push(NUDGE_MSG(minutes));
        state.lastNudgeAt = now;
      }
    },
  };
};

export default ControlFreak;
