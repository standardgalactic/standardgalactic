(() => {
  const terminal = document.getElementById("terminal");
  const form = document.getElementById("command-form");
  const input = document.getElementById("command-input");

  const cinematicFeed = [
    "[boot] loading synthetic cryptographic observatory...",
    "[init] entropy lens calibrated :: baseline 7.98 bits/byte",
    "[scan] replaying archived protocol transcript set delta-42",
    "[trace] malformed envelope catalog synchronized",
    "[diag] signature chain heuristic awaiting operator query",
    "[monitor] localhost-only transport guard is active",
  ];

  function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  function randomIp() {
    return `${randomInt(10, 223)}.${randomInt(0, 255)}.${randomInt(0, 255)}.${randomInt(1, 254)}`;
  }

  function randomFeed(amount) {
    const pool = [
      "[sim] indexing synthetic forensic artifact graph...",
      "[sim] verifying challenge vector checksum set...",
      "[sim] parsing legacy certificate fragments...",
      "[sim] tokenizing odd protocol delimiter stream...",
      "[sim] replaying deterministic handshake branch...",
      "[sim] entropy variance remains within puzzle threshold...",
      "[sim] corrupted container branch isolated for analysis...",
      "[sim] state-machine path divergence captured...",
    ];

    return Array.from({ length: amount }, () => pool[randomInt(0, pool.length - 1)]);
  }

  const commandHandlers = {
    help: () => [
      "available commands:",
      "  help              - show this message",
      "  status            - show simulator safety state",
      "  feed              - print fresh cinematic feed lines",
      "  scan              - show synthetic local service inventory",
      "  trace             - print mock packet route snapshots",
      "  decrypt           - run a fake key-recovery theater",
      "  rig               - show operator rig telemetry",
      "  puzzle            - show synthetic key puzzle diagnostics",
      "  clear             - clear terminal output",
      "  about             - describe this simulator",
    ],
    status: () => [
      "boundary: LOCAL/OFFLINE ONLY",
      "network: BLOCKED (except explicit localhost fixtures)",
      "fixtures: synthetic and auditable",
      "mode: cinematic visualization",
    ],
    feed: () => randomFeed(5),
    scan: () => {
      const services = [
        "22/tcp    OPEN   shell-gateway (simulated)",
        "53/udp    OPEN   resolver-cache (simulated)",
        "80/tcp    OPEN   static-mirror (simulated)",
        "443/tcp   OPEN   tls-vault (simulated)",
        "31337/tcp OPEN   retro-daemon (simulated)",
      ];
      return [
        `[scan] target profile: ${randomIp()} (synthetic)`,
        "[scan] baseline ports discovered:",
        ...services,
        "[scan] verdict: no external contact attempted",
      ];
    },
    trace: () => {
      const source = randomIp();
      const route = [randomIp(), randomIp(), randomIp(), "127.0.0.1"];
      return [
        `[trace] source node: ${source}`,
        `[trace] hop 1 -> ${route[0]} :: latency 4ms`,
        `[trace] hop 2 -> ${route[1]} :: latency 11ms`,
        `[trace] hop 3 -> ${route[2]} :: latency 19ms`,
        `[trace] hop 4 -> ${route[3]} :: latency 2ms`,
        "[trace] terminal hop confirmed inside local simulation boundary",
      ];
    },
    decrypt: () => {
      const windows = [
        "0x8f4c2a",
        "0x8f4c7f",
        "0x8f4cd1",
        "0x8f4d24",
      ];
      return [
        "[crypto] loading synthetic envelope set sigma-9",
        "[crypto] deriving deterministic rainbow index",
        ...windows.map((value, index) => `[crypto] window ${index + 1}/4 -> ${value}`),
        "[crypto] key candidate accepted :: fixture checksum matched",
        "[crypto] note: this is theatrical output only",
      ];
    },
    rig: () => [
      "[rig] monitor-grid ............ online",
      "[rig] keyboard-macro-deck ..... armed",
      "[rig] packet-lens ............. synthetic mode",
      "[rig] entropy-core ............ stable",
      `[rig] operator focus score .... ${randomInt(84, 99)}%`,
    ],
    puzzle: () => [
      "KEY MATERIAL INCONSISTENT :: simulated fixture",
      "SIGNATURE CHAIN UNRESOLVED :: synthetic challenge state",
      "NONCANONICAL PRIVATE COMPONENT :: authored anomaly",
      "KDF PARAMETER DRIFT :: analysis drill marker",
    ],
    about: () => [
      "Hollywood Terminal Simulator",
      "A visual, local-only, non-operational terminal theater for typing and exploration.",
      "No intrusion tooling, no stealth behavior, no external host contact.",
    ],
  };

  function appendLine(text, className = "") {
    const span = document.createElement("span");
    span.className = `line ${className}`.trim();
    span.textContent = text;
    terminal.appendChild(span);
    terminal.scrollTop = terminal.scrollHeight;
  }

  function boot() {
    appendLine("hacking-tools // hollywood terminal simulator", "good");
    appendLine("type `help` for commands", "dim");
    cinematicFeed.forEach((line) => appendLine(line));
  }

  function executeCommand(raw) {
    const cmd = raw.trim().toLowerCase();
    appendLine(`operator@hacking-tools:~$ ${raw}`, "dim");

    if (!cmd) {
      return;
    }

    if (cmd === "clear") {
      terminal.textContent = "";
      return;
    }

    const handler = commandHandlers[cmd];
    if (!handler) {
      appendLine(`unknown command: ${cmd}`, "warn");
      appendLine("try: help", "warn");
      return;
    }

    handler().forEach((line) => appendLine(line));
  }

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    executeCommand(input.value);
    input.value = "";
  });

  setInterval(() => {
    if (document.activeElement === input) {
      return;
    }
    appendLine(randomFeed(1)[0], "dim");
  }, 2400);

  boot();
})();
