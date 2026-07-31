(() => {
  const arena = document.getElementById("arena");
  const scoreEl = document.getElementById("score");
  const livesEl = document.getElementById("lives");
  const waveEl = document.getElementById("wave");
  const accuracyEl = document.getElementById("accuracy");
  const promptEl = document.getElementById("prompt");

  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  let invaders = [];
  let score = 0;
  let lives = 5;
  let wave = 1;
  let spawned = 0;
  let hits = 0;
  let misses = 0;
  let frame = null;
  let lastSpawnTime = 0;
  let running = false;

  function updateHud() {
    scoreEl.textContent = String(score);
    livesEl.textContent = String(lives);
    waveEl.textContent = String(wave);
    const attempts = hits + misses;
    const accuracy = attempts === 0 ? 100 : Math.round((hits / attempts) * 100);
    accuracyEl.textContent = `${accuracy}%`;
  }

  function randomLetter() {
    return alphabet[Math.floor(Math.random() * alphabet.length)];
  }

  function spawnInterval() {
    return Math.max(220, 900 - wave * 70);
  }

  function fallSpeed() {
    return Math.min(120, 30 + wave * 7);
  }

  function createInvader(now) {
    const node = document.createElement("span");
    const letter = randomLetter();
    node.className = "invader";
    node.textContent = letter;

    const width = arena.clientWidth;
    const x = 10 + Math.random() * Math.max(10, width - 30);
    const invader = {
      letter,
      x,
      y: -18,
      speed: fallSpeed() + Math.random() * 30,
      node,
    };

    node.style.left = `${x}px`;
    node.style.top = `${invader.y}px`;
    arena.appendChild(node);
    invaders.push(invader);

    spawned += 1;
    if (spawned % 20 === 0) {
      wave += 1;
      promptEl.textContent = `Wave ${wave}: faster drops and tighter spawn timing.`;
    }

    lastSpawnTime = now;
  }

  function removeInvader(index, wasHit) {
    const [invader] = invaders.splice(index, 1);
    if (!invader) return;

    if (wasHit) {
      invader.node.classList.add("hit");
      setTimeout(() => invader.node.remove(), 60);
      score += 10 + wave;
      hits += 1;
    } else {
      invader.node.remove();
      lives -= 1;
      misses += 1;
    }

    updateHud();
  }

  function loop(now) {
    if (!running) return;

    if (now - lastSpawnTime >= spawnInterval()) {
      createInvader(now);
    }

    const maxY = arena.clientHeight - 18;
    for (let i = invaders.length - 1; i >= 0; i -= 1) {
      const invader = invaders[i];
      invader.y += invader.speed * 0.016;
      invader.node.style.top = `${invader.y}px`;
      invader.node.style.transform = `translateY(${Math.sin(invader.y / 20) * 2}px)`;

      if (invader.y >= maxY) {
        removeInvader(i, false);
      }
    }

    if (lives <= 0) {
      running = false;
      promptEl.textContent = `Game over. Final score: ${score}. Press Enter to restart.`;
      frame = null;
      return;
    }

    frame = requestAnimationFrame(loop);
  }

  function targetIndex(letter) {
    let candidate = -1;
    let bestY = -Infinity;
    for (let i = 0; i < invaders.length; i += 1) {
      if (invaders[i].letter === letter && invaders[i].y > bestY) {
        bestY = invaders[i].y;
        candidate = i;
      }
    }
    return candidate;
  }

  function resetGame() {
    invaders.forEach((invader) => invader.node.remove());
    invaders = [];
    score = 0;
    lives = 5;
    wave = 1;
    spawned = 0;
    hits = 0;
    misses = 0;
    running = true;
    lastSpawnTime = 0;
    promptEl.textContent = "Type the falling letters. Enter starts a new game.";
    updateHud();
    if (frame !== null) {
      cancelAnimationFrame(frame);
    }
    frame = requestAnimationFrame(loop);
  }

  document.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      resetGame();
      return;
    }

    if (!running) return;

    const key = event.key.toUpperCase();
    if (key.length !== 1 || !alphabet.includes(key)) return;

    const index = targetIndex(key);
    if (index >= 0) {
      removeInvader(index, true);
      promptEl.textContent = `Confirmed: ${key}`;
    } else {
      misses += 1;
      promptEl.textContent = `No active invader for ${key}`;
      updateHud();
    }
  });

  resetGame();
})();
