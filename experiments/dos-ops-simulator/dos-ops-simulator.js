(() => {
  const screen = document.getElementById("screen");
  const prompt = document.getElementById("prompt");
  const cmdInput = document.getElementById("cmd");

  const filesystem = {
    "C:\\": ["TOOLS", "LOGS", "VAULT", "README.TXT"],
    "C:\\TOOLS": ["NETCHK.EXE", "SIGNAL.BAT", "TRACE.COM", "ARCHIVE"],
    "C:\\TOOLS\\ARCHIVE": ["BATCH93.BAK", "NOTES.LOG"],
    "C:\\LOGS": ["OPS-0001.LOG", "OPS-0002.LOG", "OPS-0003.LOG"],
    "C:\\VAULT": ["KEYRING.DAT", "TRANSCRIPT.CAB"],
  };

  let currentPath = "C:\\";

  function appendLine(text, className = "") {
    const line = document.createElement("span");
    line.className = `line ${className}`.trim();
    line.textContent = text;
    screen.appendChild(line);
    screen.scrollTop = screen.scrollHeight;
  }

  function normalizePath(path) {
    return path.replace(/\\+$/, "") || "C:\\";
  }

  function resolvePath(target) {
    if (!target || target === ".") {
      return currentPath;
    }
    if (target === "..") {
      if (currentPath === "C:\\") {
        return currentPath;
      }
      const pieces = currentPath.split("\\").filter(Boolean);
      pieces.pop();
      return pieces.length ? `C:\\${pieces.join("\\")}` : "C:\\";
    }
    if (/^c:\\/i.test(target)) {
      return normalizePath(target.toUpperCase());
    }
    return normalizePath(`${currentPath}${currentPath.endsWith("\\") ? "" : "\\"}${target.toUpperCase()}`);
  }

  function listDirectory(targetPath = currentPath) {
    const items = filesystem[targetPath];
    if (!items) {
      return ["File Not Found", "Path is not part of this simulation."];
    }
    return [` Directory of ${targetPath}`, "", ...items.map((item) => ` ${item}`), "", `${items.length} item(s)`];
  }

  function fakeScan() {
    return [
      "Initiating retro network scan...",
      "[+] NODE-01 10.21.0.4   STATUS: ONLINE",
      "[+] NODE-02 10.21.0.7   STATUS: ONLINE",
      "[+] NODE-03 10.21.0.12  STATUS: STANDBY",
      "[i] All endpoints are synthetic fixtures.",
    ];
  }

  function fakeSignal() {
    return [
      "SIGNAL.BAT executing...",
      "routing decoder pulses ................ PASS",
      "relay synchronization ................. PASS",
      "uplink handshake emulation ............ PASS",
      "operation complete.",
    ];
  }

  const commands = {
    HELP: () => [
      "Available commands:",
      "  HELP                Show this message",
      "  DIR [PATH]          List files in a folder",
      "  CD <PATH>           Change simulated directory",
      "  TYPE README.TXT     Print mission notes",
      "  SCAN                Run synthetic node scan",
      "  SIGNAL              Execute retro ops batch",
      "  CLS                 Clear terminal",
      "  VER                 Show simulator version",
    ],
    DIR: (arg) => listDirectory(resolvePath(arg)),
    CD: (arg) => {
      const target = resolvePath(arg);
      if (!filesystem[target]) {
        return ["The system cannot find the path specified."];
      }
      currentPath = target;
      return [`Current path: ${currentPath}`];
    },
    TYPE: (arg) => {
      if ((arg || "").toUpperCase() !== "README.TXT") {
        return ["File Not Found"];
      }
      return [
        "README.TXT",
        "----------",
        "DOS Ops Simulator",
        "A Mr. Robot-inspired terminal theater for offline demos.",
        "All outputs are fictional and local-only.",
      ];
    },
    SCAN: () => fakeScan(),
    SIGNAL: () => fakeSignal(),
    VER: () => ["DOS Ops Simulator v1.0", "Build: SYNTH-1987", "Mode: Offline/Cinematic"],
  };

  function runCommand(raw) {
    appendLine(`${currentPath}>${raw}`, "dim");
    const trimmed = raw.trim();
    if (!trimmed) {
      return;
    }

    const [name, ...rest] = trimmed.split(/\s+/);
    const command = name.toUpperCase();
    const arg = rest.join(" ");

    if (command === "CLS") {
      screen.textContent = "";
      return;
    }

    const handler = commands[command];
    if (!handler) {
      appendLine("Bad command or file name", "warn");
      return;
    }

    handler(arg).forEach((line) => appendLine(line, "good"));
  }

  prompt.addEventListener("submit", (event) => {
    event.preventDefault();
    runCommand(cmdInput.value);
    cmdInput.value = "";
  });

  appendLine("DOS Ops Simulator // Synthetic Operations Console", "good");
  appendLine("Type HELP to begin", "dim");
})();
