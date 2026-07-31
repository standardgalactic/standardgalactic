(() => {
  "use strict";

  const WIDTH = 5;
  const DEPTH = 5;
  const HEIGHT = 12;

  const WELL_CENTER_X = 360;
  const WELL_CENTER_Y = 300;
  const OPENING = 420;
  const SPAWN_Z = -3;
  const TOSS_MS = 95;
  const LOCK_DELAY_MS = 500;
  const MAX_LOCK_RESETS = 15;

  const KICK_OFFSETS = [
    [0, 0, 0],
    [1, 0, 0], [-1, 0, 0],
    [0, 1, 0], [0, -1, 0],
    [1, 1, 0], [-1, -1, 0], [1, -1, 0], [-1, 1, 0],
    [0, 0, -1]
  ];

  const COLORS = [
    "#ef4444", "#f59e0b", "#84cc16", "#22d3ee", "#60a5fa", "#a78bfa",
    "#f472b6", "#fb7185", "#eab308", "#38bdf8", "#34d399", "#f97316"
  ];

  const BRICKS = [
    { name: "I", cells: [[0,0,0],[1,0,0],[2,0,0],[3,0,0]] },
    { name: "L", cells: [[0,0,0],[0,1,0],[0,2,0],[1,2,0]] },
    { name: "T", cells: [[0,0,0],[1,0,0],[2,0,0],[1,1,0]] },
    { name: "S", cells: [[1,0,0],[2,0,0],[0,1,0],[1,1,0]] },
    { name: "Square", cells: [[0,0,0],[1,0,0],[0,1,0],[1,1,0]] },
    { name: "Skew", cells: [[0,0,0],[1,0,0],[1,1,0],[2,1,0]] },
    { name: "XYZ Corner", cells: [[0,0,0],[1,0,0],[0,1,0],[0,0,1]] },
    { name: "Twisted Stair", cells: [[0,0,0],[1,0,0],[1,0,1],[1,1,1]] },
    { name: "Raised T", cells: [[0,0,0],[1,0,0],[2,0,0],[1,0,1]] },
    { name: "Tripod", cells: [[0,0,0],[1,0,0],[0,1,0],[0,0,1]] },
    { name: "Pillar L", cells: [[0,0,0],[0,0,1],[0,0,2],[1,0,2]] },
    { name: "Bridge", cells: [[0,0,0],[1,0,0],[2,0,0],[1,1,1]] }
  ].map((brick, i) => ({
    ...brick,
    color: COLORS[i % COLORS.length],
    orientations: generateOrientations(brick.cells)
  }));

  const gameCanvas = document.getElementById("game");
  const nextCanvas = document.getElementById("next");
  const scoreEl = document.getElementById("score");
  const levelEl = document.getElementById("level");
  const floorsEl = document.getElementById("floors");
  const statusEl = document.getElementById("status");

  const ctx = gameCanvas.getContext("2d");
  const nctx = nextCanvas.getContext("2d");

  const audioCtx = new (window.AudioContext || window.webkitAudioContext)();

  const state = {
    well: createWell(),
    active: null,
    next: pickBrick(),
    score: 0,
    level: 1,
    floors: 0,
    gameOver: false,
    paused: false,
    started: false,
    gravityMs: 0,
    softDropMs: 0,
    lastTs: 0,
    keysDown: new Set(),
    particles: [],
    shakeMs: 0,
    tossAnim: null,
    ghostBlink: 0,
    lockDelayMs: 0,
    lockResets: 0
  };

  function createWell() {
    return Array.from({ length: HEIGHT }, () =>
      Array.from({ length: DEPTH }, () => Array(WIDTH).fill(null))
    );
  }

  function cloneCells(cells) {
    return cells.map(([x, y, z]) => [x, y, z]);
  }

  function normalize(cells) {
    let minX = Infinity;
    let minY = Infinity;
    let minZ = Infinity;
    for (const [x, y, z] of cells) {
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (z < minZ) minZ = z;
    }
    return cells
      .map(([x, y, z]) => [x - minX, y - minY, z - minZ])
      .sort((a, b) => (a[2] - b[2]) || (a[1] - b[1]) || (a[0] - b[0]));
  }

  function keyOf(cells) {
    return cells.map(([x, y, z]) => `${x},${y},${z}`).join(";");
  }

  function rotateX(cells) {
    return normalize(cells.map(([x, y, z]) => [x, -z, y]));
  }

  function rotateY(cells) {
    return normalize(cells.map(([x, y, z]) => [z, y, -x]));
  }

  function rotateZ(cells) {
    return normalize(cells.map(([x, y, z]) => [-y, x, z]));
  }

  function generateOrientations(baseCells) {
    const seen = new Set();
    const out = [];
    const queue = [normalize(baseCells)];

    while (queue.length) {
      const cells = queue.shift();
      const key = keyOf(cells);
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(cells);

      queue.push(rotateX(cells), rotateY(cells), rotateZ(cells));
    }

    return out;
  }

  function pickBrick() {
    const proto = BRICKS[Math.floor(Math.random() * BRICKS.length)];
    return {
      name: proto.name,
      color: proto.color,
      orientations: proto.orientations,
      orientationIndex: 0,
      pos: { x: 0, y: 0, z: SPAWN_Z }
    };
  }

  function activeCells(piece = state.active) {
    return piece.orientations[piece.orientationIndex];
  }

  function bounds(cells) {
    let maxX = 0, maxY = 0, maxZ = 0;
    for (const [x, y, z] of cells) {
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
      if (z > maxZ) maxZ = z;
    }
    return { maxX, maxY, maxZ };
  }

  function absoluteCells(cells, pos) {
    return cells.map(([x, y, z]) => ({ x: x + pos.x, y: y + pos.y, z: z + pos.z }));
  }

  function isValid(cells, pos) {
    for (const c of absoluteCells(cells, pos)) {
      if (c.x < 0 || c.x >= WIDTH) return false;
      if (c.y < 0 || c.y >= DEPTH) return false;
      if (c.z >= HEIGHT) return false;
      if (c.z >= 0 && state.well[c.z][c.y][c.x] !== null) return false;
    }
    return true;
  }

  function canSpawnEnter(brick) {
    const cells = activeCells(brick);
    const b = bounds(cells);
    for (let y = 0; y <= DEPTH - (b.maxY + 1); y++) {
      for (let x = 0; x <= WIDTH - (b.maxX + 1); x++) {
        if (isValid(cells, { x, y, z: 0 })) return true;
      }
    }
    return false;
  }

  function spawnBrick() {
    const brick = state.next;
    brick.orientationIndex = 0;

    const b = bounds(activeCells(brick));
    brick.pos = {
      x: Math.floor((WIDTH - (b.maxX + 1)) / 2),
      y: Math.floor((DEPTH - (b.maxY + 1)) / 2),
      z: SPAWN_Z
    };

    if (!canSpawnEnter(brick) || !isValid(activeCells(brick), brick.pos)) {
      state.gameOver = true;
      statusEl.textContent = "No space for another brick.";
      return;
    }

    state.active = brick;
    state.next = pickBrick();
  }

  function tryMove(dx, dy, dz) {
    if (!state.active || state.tossAnim) return false;
    const pos = {
      x: state.active.pos.x + dx,
      y: state.active.pos.y + dy,
      z: state.active.pos.z + dz
    };
    if (isValid(activeCells(), pos)) {
      state.active.pos = pos;
      if (dz <= 0) resetLockDelay();
      return true;
    }
    return false;
  }

  function tryRotate(axis) {
    if (!state.active || state.tossAnim) return;
    const current = activeCells();
    const target = axis === "x" ? rotateX(current) : axis === "y" ? rotateY(current) : rotateZ(current);
    const key = keyOf(target);
    const idx = state.active.orientations.findIndex((o) => keyOf(o) === key);
    if (idx < 0) return;

    const targetCells = state.active.orientations[idx];
    for (const [dx, dy, dz] of KICK_OFFSETS) {
      const pos = {
        x: state.active.pos.x + dx,
        y: state.active.pos.y + dy,
        z: state.active.pos.z + dz
      };
      if (isValid(targetCells, pos)) {
        state.active.orientationIndex = idx;
        state.active.pos = pos;
        resetLockDelay();
        playTone(180, 0.02, "square");
        return;
      }
    }
  }

  function isGrounded() {
    if (!state.active) return false;
    return !isValid(activeCells(), { ...state.active.pos, z: state.active.pos.z + 1 });
  }

  function resetLockDelay() {
    if (isGrounded() && state.lockResets < MAX_LOCK_RESETS) {
      state.lockDelayMs = 0;
      state.lockResets++;
    }
  }

  function computeGhostPos() {
    if (!state.active) return null;
    const cells = activeCells();
    const pos = { ...state.active.pos };
    while (isValid(cells, { ...pos, z: pos.z + 1 })) {
      pos.z++;
    }
    return pos;
  }

  function floorScore(cleared) {
    if (cleared === 1) return 250 * state.level;
    if (cleared === 2) return 750 * state.level;
    if (cleared === 3) return 1500 * state.level;
    return 3000 * state.level;
  }

  function clearFloors() {
    let cleared = 0;
    for (let z = HEIGHT - 1; z >= 0; z--) {
      let full = true;
      for (let y = 0; y < DEPTH && full; y++) {
        for (let x = 0; x < WIDTH; x++) {
          if (state.well[z][y][x] === null) {
            full = false;
            break;
          }
        }
      }

      if (full) {
        spawnParticles(z);
        cleared++;
        for (let zz = z; zz > 0; zz--) {
          for (let y = 0; y < DEPTH; y++) {
            for (let x = 0; x < WIDTH; x++) {
              state.well[zz][y][x] = state.well[zz - 1][y][x];
            }
          }
        }
        for (let y = 0; y < DEPTH; y++) {
          for (let x = 0; x < WIDTH; x++) {
            state.well[0][y][x] = null;
          }
        }
        z++;
      }
    }
    return cleared;
  }

  function lockBrick() {
    if (!state.active) return;
    const cells = activeCells();
    for (const c of absoluteCells(cells, state.active.pos)) {
      if (c.z >= 0) state.well[c.z][c.y][c.x] = state.active.color;
    }

    const cleared = clearFloors();
    if (cleared > 0) {
      state.score += floorScore(cleared);
      state.floors += cleared;
      statusEl.textContent = `Floor clear x${cleared}`;
      playTone(350, 0.07, "square");
    } else {
      state.score += 10;
      statusEl.textContent = "Find the cavity.";
      playTone(120, 0.03, "square");
    }

    state.level = 1 + Math.floor(state.floors / 5);
    state.shakeMs = 90;
    state.active = null;
    state.lockDelayMs = 0;
    state.lockResets = 0;
    spawnBrick();
  }

  function gravityInterval() {
    return Math.max(100, Math.round(1000 * Math.pow(0.85, state.level - 1)));
  }

  function toss() {
    if (!state.active || state.tossAnim || state.paused || state.gameOver) return;
    const targetPos = computeGhostPos();
    const dz = targetPos.z - state.active.pos.z;
    if (dz > 0) state.score += dz * 2;

    state.tossAnim = {
      fromZ: state.active.pos.z,
      toZ: targetPos.z,
      elapsed: 0
    };
    playTone(220, 0.05, "square");
  }

  function updateToss(dt) {
    if (!state.tossAnim || !state.active) return;
    state.tossAnim.elapsed += dt;
    const t = Math.min(1, state.tossAnim.elapsed / TOSS_MS);
    const eased = 1 - Math.pow(1 - t, 3);
    const z = state.tossAnim.fromZ + (state.tossAnim.toZ - state.tossAnim.fromZ) * eased;
    state.active.pos.z = Math.round(z);

    if (t >= 1) {
      state.active.pos.z = state.tossAnim.toZ;
      state.tossAnim = null;
      lockBrick();
    }
  }

  function project(x, y, z) {
    const zn = Math.max(0, z) / (HEIGHT - 1);
    const scale = 1 - zn * 0.62;
    const cellW = (OPENING / WIDTH) * scale;
    const cellH = (OPENING / DEPTH) * scale;
    const cx = WELL_CENTER_X + ((x + 0.5) / WIDTH - 0.5) * OPENING * scale;
    const cy = WELL_CENTER_Y + ((y + 0.5) / DEPTH - 0.5) * OPENING * scale;
    return { x: cx - cellW / 2, y: cy - cellH / 2, w: cellW, h: cellH, scale };
  }

  function drawCube(c, color, alpha = 1, wire = false) {
    const p = project(c.x, c.y, c.z);
    ctx.save();
    ctx.globalAlpha = alpha;

    if (wire) {
      ctx.strokeStyle = "rgba(190, 255, 190, 0.9)";
      ctx.lineWidth = 1;
      ctx.strokeRect(p.x + 0.5, p.y + 0.5, p.w - 1, p.h - 1);
      ctx.restore();
      return;
    }

    ctx.fillStyle = color;
    ctx.fillRect(p.x, p.y, p.w, p.h);

    ctx.fillStyle = "rgba(255,255,255,0.24)";
    ctx.fillRect(p.x, p.y, p.w, Math.max(2, p.h * 0.18));

    ctx.fillStyle = "rgba(0,0,0,0.3)";
    ctx.fillRect(p.x + p.w * 0.72, p.y, p.w * 0.28, p.h);

    ctx.strokeStyle = "#000";
    ctx.strokeRect(p.x + 0.5, p.y + 0.5, p.w - 1, p.h - 1);
    ctx.restore();
  }

  function drawChamber() {
    ctx.fillStyle = "#04050b";
    ctx.fillRect(0, 0, gameCanvas.width, gameCanvas.height);

    for (let z = HEIGHT - 1; z >= 0; z -= 2) {
      const zn = z / (HEIGHT - 1);
      const scale = 1 - zn * 0.62;
      const size = OPENING * scale;
      ctx.strokeStyle = z % 4 === 0 ? "rgba(118,144,198,0.30)" : "rgba(78,94,142,0.22)";
      ctx.strokeRect(WELL_CENTER_X - size / 2, WELL_CENTER_Y - size / 2, size, size);
    }

    ctx.strokeStyle = "#9fb7ef";
    ctx.lineWidth = 2;
    ctx.strokeRect(WELL_CENTER_X - OPENING / 2, WELL_CENTER_Y - OPENING / 2, OPENING, OPENING);

    ctx.strokeStyle = "rgba(255,255,255,0.08)";
    ctx.strokeRect(12, 12, gameCanvas.width - 24, gameCanvas.height - 24);
  }

  function drawWellBricks() {
    const blocks = [];
    for (let z = 0; z < HEIGHT; z++) {
      for (let y = 0; y < DEPTH; y++) {
        for (let x = 0; x < WIDTH; x++) {
          const color = state.well[z][y][x];
          if (color) blocks.push({ x, y, z, color });
        }
      }
    }
    blocks.sort((a, b) => b.z - a.z);
    blocks.forEach((b) => drawCube(b, b.color));
  }

  function drawGhost() {
    if (!state.active || state.gameOver) return;
    const blink = Math.sin(state.ghostBlink * 0.01) > 0;
    if (!blink) return;
    const ghost = computeGhostPos();
    const cells = absoluteCells(activeCells(), ghost);
    cells.forEach((c) => { if (c.z >= 0) drawCube(c, "#9cff9c", 1, true); });
  }

  function drawActive() {
    if (!state.active || state.gameOver) return;
    const cells = absoluteCells(activeCells(), state.active.pos);
    cells
      .filter((c) => c.z >= -3)
      .sort((a, b) => b.z - a.z)
      .forEach((c) => {
        if (c.z < 0) {
          drawCube({ ...c, z: 0 }, state.active.color, 0.5);
        } else {
          drawCube(c, state.active.color, 1);
        }
      });
  }

  function drawParticles(dt) {
    for (let i = state.particles.length - 1; i >= 0; i--) {
      const p = state.particles[i];
      p.life -= dt;
      p.x += p.vx * dt * 0.016;
      p.y += p.vy * dt * 0.016;
      p.vy += 0.006 * dt;

      const alpha = Math.max(0, p.life / p.maxLife);
      ctx.fillStyle = `rgba(200,230,255,${alpha})`;
      ctx.fillRect(p.x, p.y, 2, 2);

      if (p.life <= 0) state.particles.splice(i, 1);
    }
  }

  function spawnParticles(z) {
    for (let i = 0; i < 45; i++) {
      const p = project(Math.random() * (WIDTH - 1), Math.random() * (DEPTH - 1), z);
      state.particles.push({
        x: p.x + p.w * Math.random(),
        y: p.y + p.h * Math.random(),
        vx: (Math.random() - 0.5) * 3,
        vy: (Math.random() - 0.7) * 2,
        life: 280 + Math.random() * 220,
        maxLife: 420
      });
    }
  }

  function drawNext() {
    nctx.fillStyle = "#060611";
    nctx.fillRect(0, 0, nextCanvas.width, nextCanvas.height);

    const cells = state.next.orientations[0];
    const b = bounds(cells);
    const s = 20;
    const ox = nextCanvas.width / 2 - ((b.maxX + 1) * s) / 2;
    const oy = nextCanvas.height / 2 - ((b.maxY + 1) * s) / 2;

    for (const [x, y] of cells) {
      nctx.fillStyle = state.next.color;
      nctx.fillRect(ox + x * s, oy + y * s, s, s);
      nctx.fillStyle = "rgba(255,255,255,0.2)";
      nctx.fillRect(ox + x * s, oy + y * s, s, 3);
      nctx.strokeStyle = "#000";
      nctx.strokeRect(ox + x * s + 0.5, oy + y * s + 0.5, s - 1, s - 1);
    }
  }

  function drawOverlay() {
    if (state.paused || state.gameOver) {
      ctx.fillStyle = "rgba(0,0,0,0.58)";
      ctx.fillRect(0, 0, gameCanvas.width, gameCanvas.height);
      ctx.fillStyle = "#f8fafc";
      ctx.font = "bold 40px Courier New";
      ctx.textAlign = "center";
      ctx.fillText(state.gameOver ? "WELL JAMMED" : "PAUSED", gameCanvas.width / 2, gameCanvas.height / 2);
      ctx.font = "18px Courier New";
      ctx.fillText("Press R to restart", gameCanvas.width / 2, gameCanvas.height / 2 + 30);
    }
  }

  function drawFrame(dt) {
    const shake = state.shakeMs > 0 ? 1 + (Math.random() * 2 | 0) : 0;
    ctx.save();
    ctx.translate(shake, -shake);
    drawChamber();
    drawWellBricks();
    drawGhost();
    drawActive();
    drawParticles(dt);
    drawOverlay();
    ctx.restore();
    drawNext();
  }

  function updateHUD() {
    scoreEl.textContent = String(state.score).padStart(7, "0");
    levelEl.textContent = String(state.level).padStart(2, "0");
    floorsEl.textContent = String(state.floors).padStart(2, "0");
  }

  function playTone(freq, duration, type = "square") {
    if (audioCtx.state === "suspended") audioCtx.resume();
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.type = type;
    osc.frequency.value = freq;
    gain.gain.value = 0.02;
    osc.connect(gain);
    gain.connect(audioCtx.destination);
    osc.start();
    gain.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + duration);
    osc.stop(audioCtx.currentTime + duration);
  }

  function restart() {
    state.well = createWell();
    state.active = null;
    state.next = pickBrick();
    state.score = 0;
    state.level = 1;
    state.floors = 0;
    state.gameOver = false;
    state.paused = false;
    state.started = false;
    state.gravityMs = 0;
    state.softDropMs = 0;
    state.lastTs = 0;
    state.keysDown.clear();
    state.particles = [];
    state.shakeMs = 0;
    state.tossAnim = null;
    state.ghostBlink = 0;
    state.lockDelayMs = 0;
    state.lockResets = 0;
    statusEl.textContent = "Align a hovering brick, then toss it.";
  }

  function startIfNeeded() {
    if (!state.started) {
      state.started = true;
      spawnBrick();
      statusEl.textContent = "Hover, rotate, and toss.";
    }
  }

  function onKeyDown(e) {
    if (["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown", "Space"].includes(e.code)) {
      e.preventDefault();
    }

    if (e.code === "KeyR") {
      restart();
      return;
    }
    if (e.code === "KeyP") {
      if (!state.gameOver) {
        state.paused = !state.paused;
        statusEl.textContent = state.paused ? "Paused." : "Back to tossing.";
      }
      return;
    }

    if (state.paused || state.gameOver) return;
    startIfNeeded();

    switch (e.code) {
      case "ArrowLeft": tryMove(-1, 0, 0); break;
      case "ArrowRight": tryMove(1, 0, 0); break;
      case "ArrowUp": tryMove(0, -1, 0); break;
      case "ArrowDown":
        if (tryMove(0, 0, 1)) state.score += 1;
        break;
      case "KeyQ": tryRotate("x"); break;
      case "KeyW": tryRotate("y"); break;
      case "KeyE": tryRotate("z"); break;
      case "Space": toss(); break;
      default: break;
    }

    state.keysDown.add(e.code);
  }

  function onKeyUp(e) {
    state.keysDown.delete(e.code);
  }

  function loop(ts) {
    if (!state.lastTs) state.lastTs = ts;
    const dt = Math.min(40, ts - state.lastTs);
    state.lastTs = ts;

    if (state.started && !state.paused && !state.gameOver && state.active) {
      state.gravityMs += dt;
      state.softDropMs += dt;
      state.ghostBlink += dt;
      if (state.shakeMs > 0) state.shakeMs = Math.max(0, state.shakeMs - dt);

      updateToss(dt);

      if (!state.tossAnim) {
        if (state.gravityMs >= gravityInterval()) {
          state.gravityMs = 0;
          tryMove(0, 0, 1);
        }

        if (isGrounded()) {
          state.lockDelayMs += dt;
          if (state.lockDelayMs >= LOCK_DELAY_MS) {
            lockBrick();
          }
        } else {
          state.lockDelayMs = 0;
          state.lockResets = 0;
        }

        if (state.keysDown.has("ArrowDown") && state.softDropMs >= 55) {
          state.softDropMs = 0;
          if (tryMove(0, 0, 1)) state.score += 1;
        }
      }
    }

    drawFrame(dt);
    updateHUD();
    requestAnimationFrame(loop);
  }

  function selfChecks() {
    const sample = normalize([[0,0,0],[1,0,0],[2,0,0],[3,0,0]]);

    let r = cloneCells(sample);
    for (let i = 0; i < 4; i++) r = rotateX(r);
    if (keyOf(r) !== keyOf(sample)) throw new Error("rotateX failed four-turn cycle");

    r = cloneCells(sample);
    for (let i = 0; i < 4; i++) r = rotateY(r);
    if (keyOf(r) !== keyOf(sample)) throw new Error("rotateY failed four-turn cycle");

    r = cloneCells(sample);
    for (let i = 0; i < 4; i++) r = rotateZ(r);
    if (keyOf(r) !== keyOf(sample)) throw new Error("rotateZ failed four-turn cycle");

    if (!Array.isArray(createWell()[0][0])) throw new Error("well[z][y][x] shape invalid");

    const prior = state.well;
    state.well = createWell();
    for (let y = 0; y < DEPTH; y++) {
      for (let x = 0; x < WIDTH; x++) {
        state.well[HEIGHT - 1][y][x] = "#fff";
      }
    }
    const cleared = clearFloors();
    state.well = prior;
    if (cleared !== 1) throw new Error("clearFloors should clear full floor");
  }

  window.addEventListener("keydown", onKeyDown);
  window.addEventListener("keyup", onKeyUp);

  selfChecks();
  restart();
  drawFrame(16);
  updateHUD();
  requestAnimationFrame(loop);
})();
