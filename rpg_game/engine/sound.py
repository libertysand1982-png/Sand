"""
Procedural sound engine for La Forêt de Brume.
All audio is generated via numpy + wave — no external sound files needed.
Sounds are cached as .wav files in rpg_game/sounds/.
Playback uses pygame.mixer (if available).
"""

import os
import struct
import threading
import wave

try:
    import numpy as np
    _NP_AVAILABLE = True
except ImportError:
    _NP_AVAILABLE = False

try:
    import pygame
    _PG_AVAILABLE = True
except ImportError:
    _PG_AVAILABLE = False

SOUNDS_DIR = os.path.join(os.path.dirname(__file__), '..', 'sounds')
SAMPLE_RATE = 44100


# ─────────────────────────────────────────────
# LOW-LEVEL GENERATION HELPERS
# ─────────────────────────────────────────────

def _silence(duration, sample_rate=SAMPLE_RATE):
    return np.zeros(int(sample_rate * duration), dtype=np.float32)


def generate_sine(freq, duration, volume=0.5, sample_rate=SAMPLE_RATE):
    """Simple sine wave."""
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    return (np.sin(2 * np.pi * freq * t) * volume).astype(np.float32)


def generate_noise(duration, volume=0.3, sample_rate=SAMPLE_RATE):
    """White noise."""
    n = int(sample_rate * duration)
    return (np.random.uniform(-1, 1, n) * volume).astype(np.float32)


# ─────────────────────────────────────────────
# SOUND EFFECT GENERATORS
# ─────────────────────────────────────────────

def generate_sword_hit():
    """Metal clang: high-freq noise burst + low thud, 0.3s."""
    sr = SAMPLE_RATE
    dur = 0.3
    n = int(sr * dur)
    t = np.linspace(0, dur, n, endpoint=False)

    # High-freq noise (metal clang) with fast exponential decay
    noise = np.random.uniform(-1, 1, n).astype(np.float32)
    # Simple bandpass approximation: multiply noise by a carrier around 3000 Hz
    carrier = np.sin(2 * np.pi * 3000 * t).astype(np.float32)
    clang = noise * carrier * np.exp(-t * 20).astype(np.float32) * 0.6

    # Low thud at 200 Hz
    thud = (np.sin(2 * np.pi * 200 * t) * np.exp(-t * 15) * 0.4).astype(np.float32)

    result = np.clip(clang + thud, -1.0, 1.0)
    return result.astype(np.float32)


def generate_spell_cast():
    """Magical shimmer: rising sweep 400→1200 Hz with harmonics + echo, 0.6s."""
    sr = SAMPLE_RATE
    dur = 0.6
    n = int(sr * dur)
    t = np.linspace(0, dur, n, endpoint=False)

    # Frequency sweep
    freq = 400 + 800 * (t / dur)
    phase = np.cumsum(2 * np.pi * freq / sr)
    base = np.sin(phase).astype(np.float32) * 0.4

    # Harmonics
    harm1 = np.sin(phase * 1.5).astype(np.float32) * 0.2
    harm2 = np.sin(phase * 2.0).astype(np.float32) * 0.1

    combined = (base + harm1 + harm2) * np.exp(-t * 1.5).astype(np.float32)

    # Simple echo: delay by 0.1s
    delay_samples = int(0.1 * sr)
    echo = np.zeros(n, dtype=np.float32)
    echo[delay_samples:] = combined[: n - delay_samples] * 0.3

    result = np.clip(combined + echo, -1.0, 1.0)
    return result.astype(np.float32)


def generate_victory():
    """Triumphant C-E-G-C fanfare, 0.7s total."""
    sr = SAMPLE_RATE
    notes = [(261, 0.15), (329, 0.15), (392, 0.15), (523, 0.25)]
    chunks = []
    for freq, dur in notes:
        n = int(sr * dur)
        t = np.linspace(0, dur, n, endpoint=False)
        tone = np.sin(2 * np.pi * freq * t) * 0.5
        # Add harmonic brightness
        tone += np.sin(2 * np.pi * freq * 2 * t) * 0.2
        tone += np.sin(2 * np.pi * freq * 3 * t) * 0.1
        # Slight fade-out at end of each note
        env = np.ones(n)
        env[-int(n * 0.15):] = np.linspace(1, 0.3, int(n * 0.15))
        chunks.append((tone * env).astype(np.float32))
    return np.clip(np.concatenate(chunks), -1.0, 1.0).astype(np.float32)


def generate_defeat():
    """Descending G-Eb-C minor, slow fade, 0.9s total."""
    sr = SAMPLE_RATE
    notes = [(392, 0.3), (311, 0.3), (261, 0.3)]
    chunks = []
    total_n = sum(int(sr * d) for _, d in notes)
    idx = 0
    for freq, dur in notes:
        n = int(sr * dur)
        t = np.linspace(0, dur, n, endpoint=False)
        fade = np.linspace(1, 0, n)
        tone = (np.sin(2 * np.pi * freq * t) * 0.4 * fade).astype(np.float32)
        chunks.append(tone)
        idx += n
    return np.clip(np.concatenate(chunks), -1.0, 1.0).astype(np.float32)


def generate_footstep():
    """Very short low-freq thud, 0.08s, randomized pitch ±10%."""
    sr = SAMPLE_RATE
    dur = 0.08
    n = int(sr * dur)
    t = np.linspace(0, dur, n, endpoint=False)
    pitch = 80 * (1 + (import_random_value() - 0.5) * 0.2)
    tone = np.sin(2 * np.pi * pitch * t) * np.exp(-t * 60) * 0.5
    noise_part = np.random.uniform(-1, 1, n) * np.exp(-t * 80) * 0.2
    return np.clip((tone + noise_part).astype(np.float32), -1.0, 1.0)


def import_random_value():
    import random
    return random.random()


def generate_door_open():
    """Low creak: 80→120 Hz sweep + wood noise texture, 0.5s."""
    sr = SAMPLE_RATE
    dur = 0.5
    n = int(sr * dur)
    t = np.linspace(0, dur, n, endpoint=False)

    freq = 80 + 40 * (t / dur)
    phase = np.cumsum(2 * np.pi * freq / sr)
    creak = np.sin(phase) * 0.3

    noise_part = np.random.uniform(-1, 1, n) * 0.15 * np.exp(-t * 4)
    combined = (creak + noise_part) * np.linspace(0.1, 0.8, n) * np.linspace(1, 0.3, n)
    return np.clip(combined.astype(np.float32), -1.0, 1.0)


def generate_monster_roar():
    """Low rumble 60-120 Hz noise burst with tremolo, 0.4s."""
    sr = SAMPLE_RATE
    dur = 0.4
    n = int(sr * dur)
    t = np.linspace(0, dur, n, endpoint=False)

    # Low-freq noise
    noise = np.random.uniform(-1, 1, n).astype(np.float32)
    # Filter with a low-freq sine carrier (approximates low-pass)
    carrier = np.sin(2 * np.pi * 90 * t).astype(np.float32)
    low_noise = noise * carrier * 0.5

    # Tremolo modulation at 8 Hz
    tremolo = (0.6 + 0.4 * np.sin(2 * np.pi * 8 * t)).astype(np.float32)
    result = low_noise * tremolo * np.exp(-t * 2)
    return np.clip(result.astype(np.float32), -1.0, 1.0)


def generate_level_up():
    """Ascending C-E-G-B-C arpeggio, 0.1s per note, bright."""
    sr = SAMPLE_RATE
    notes = [261, 329, 392, 493, 523]
    dur_each = 0.1
    chunks = []
    for freq in notes:
        n = int(sr * dur_each)
        t = np.linspace(0, dur_each, n, endpoint=False)
        tone = np.sin(2 * np.pi * freq * t) * 0.5
        tone += np.sin(2 * np.pi * freq * 2 * t) * 0.25
        tone += np.sin(2 * np.pi * freq * 3 * t) * 0.1
        env = np.ones(n)
        env[-int(n * 0.2):] = np.linspace(1, 0, int(n * 0.2))
        chunks.append((tone * env).astype(np.float32))
    return np.clip(np.concatenate(chunks), -1.0, 1.0).astype(np.float32)


def generate_coin_pickup():
    """Quick high ping 800→1200 Hz, 0.15s."""
    sr = SAMPLE_RATE
    dur = 0.15
    n = int(sr * dur)
    t = np.linspace(0, dur, n, endpoint=False)
    freq = 800 + 400 * (t / dur)
    phase = np.cumsum(2 * np.pi * freq / sr)
    tone = np.sin(phase) * 0.5 * np.exp(-t * 15)
    return np.clip(tone.astype(np.float32), -1.0, 1.0)


# ─────────────────────────────────────────────
# AMBIENT MUSIC GENERATORS
# ─────────────────────────────────────────────

def _chord(freqs, duration, volume=0.3, sr=SAMPLE_RATE):
    """Blend multiple sine waves into a chord."""
    n = int(sr * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    out = np.zeros(n, dtype=np.float32)
    for f in freqs:
        out += np.sin(2 * np.pi * f * t).astype(np.float32)
    out /= max(len(freqs), 1)
    return (out * volume).astype(np.float32)


def generate_ambient_music(style="village"):
    """Generate 8-12 second ambient loop."""
    sr = SAMPLE_RATE

    if style == "village":
        # Peaceful major: C and G chords alternating, 8s
        c_chord = _chord([261, 329, 392], 2.0, volume=0.25)
        g_chord = _chord([196, 246, 294], 2.0, volume=0.25)
        # Gentle fade between chords
        loop = np.concatenate([c_chord, g_chord, c_chord, g_chord])
        # Soft envelope
        env = np.ones(len(loop))
        fade = int(sr * 0.3)
        env[:fade] = np.linspace(0, 1, fade)
        env[-fade:] = np.linspace(1, 0, fade)
        result = loop * env

    elif style == "dungeon":
        # Dark drone: 55 Hz with dissonant overtones, 10s
        dur = 10.0
        n = int(sr * dur)
        t = np.linspace(0, dur, n, endpoint=False)
        drone = np.sin(2 * np.pi * 55 * t) * 0.3
        over1 = np.sin(2 * np.pi * 82 * t) * 0.1
        over2 = np.sin(2 * np.pi * 103 * t) * 0.08
        # Slow tremolo
        tremolo = 0.7 + 0.3 * np.sin(2 * np.pi * 0.3 * t)
        noise_bg = np.random.uniform(-1, 1, n) * 0.03
        result = ((drone + over1 + over2) * tremolo + noise_bg).astype(np.float32)

    elif style == "combat":
        # Tense fast: alternating minor chords with percussive beats, 8s
        sr_local = sr
        c_minor = _chord([261, 311, 392], 0.4, volume=0.25)
        a_minor = _chord([220, 261, 329], 0.4, volume=0.25)
        f_minor = _chord([175, 208, 261], 0.4, volume=0.25)
        beat_dur = int(sr_local * 0.05)
        beat = (np.random.uniform(-1, 1, beat_dur) * np.linspace(0.4, 0, beat_dur)).astype(np.float32)
        silence_short = np.zeros(int(sr_local * 0.35), dtype=np.float32)
        beat_measure = np.concatenate([beat, silence_short])[:int(sr_local * 0.4)]
        pattern = []
        for chord in [c_minor, a_minor, c_minor, f_minor,
                       c_minor, a_minor, f_minor, c_minor,
                       c_minor, a_minor, c_minor, f_minor,
                       c_minor, a_minor, f_minor, c_minor,
                       c_minor, a_minor, c_minor, f_minor]:
            measure = chord + beat_measure[:len(chord)]
            pattern.append(measure)
        result = np.concatenate(pattern).astype(np.float32)

    else:  # menu / default
        # Pentatonic melody: C D E G A, gentle, 10s
        penta = [261, 293, 329, 392, 440]
        import random
        chunks = []
        total = 0
        target = 10.0
        while total < target:
            f = random.choice(penta)
            d = random.choice([0.3, 0.4, 0.5, 0.6])
            n = int(sr * d)
            t_arr = np.linspace(0, d, n, endpoint=False)
            tone = (np.sin(2 * np.pi * f * t_arr) * 0.25 * np.exp(-t_arr * 3)).astype(np.float32)
            gap = np.zeros(int(sr * 0.1), dtype=np.float32)
            chunks.extend([tone, gap])
            total += d + 0.1
        result = np.concatenate(chunks)[:int(sr * target)]

    return np.clip(result, -1.0, 1.0).astype(np.float32)


# ─────────────────────────────────────────────
# WAV FILE I/O
# ─────────────────────────────────────────────

def save_wav(samples, filepath, sample_rate=SAMPLE_RATE):
    """Save a float32 numpy array as a 16-bit mono WAV file."""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    pcm = (np.clip(samples, -1.0, 1.0) * 32767).astype(np.int16)
    with wave.open(filepath, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(sample_rate)
        wf.writeframes(pcm.tobytes())


def get_sound_path(name):
    """Return path to sounds/<name>.wav, generating the file if it doesn't exist."""
    os.makedirs(SOUNDS_DIR, exist_ok=True)
    path = os.path.join(SOUNDS_DIR, f"{name}.wav")
    if not os.path.exists(path):
        generator = _SFX_GENERATORS.get(name)
        if generator:
            samples = generator()
            save_wav(samples, path)
    return path


# Mapping sfx name -> generator function
_SFX_GENERATORS = {
    "sword":   generate_sword_hit,
    "spell":   generate_spell_cast,
    "victory": generate_victory,
    "defeat":  generate_defeat,
    "step":    generate_footstep,
    "door":    generate_door_open,
    "roar":    generate_monster_roar,
    "level_up": generate_level_up,
    "coin":    generate_coin_pickup,
}

_MUSIC_GENERATORS = {
    "village": lambda: generate_ambient_music("village"),
    "dungeon": lambda: generate_ambient_music("dungeon"),
    "combat":  lambda: generate_ambient_music("combat"),
    "menu":    lambda: generate_ambient_music("menu"),
}


# ─────────────────────────────────────────────
# SOUND MANAGER
# ─────────────────────────────────────────────

class SoundManager:
    def __init__(self):
        self.enabled = True
        self.music_enabled = True
        self.sfx_volume = 0.7
        self.music_volume = 0.4
        self._current_music = None
        self._sounds = {}   # name -> pygame.mixer.Sound
        self._initialized = False

    def init(self):
        """Initialize pygame mixer. Call once at startup."""
        if not (_NP_AVAILABLE and _PG_AVAILABLE):
            return
        try:
            pygame.mixer.pre_init(SAMPLE_RATE, -16, 1, 512)
            pygame.mixer.init()
            os.makedirs(SOUNDS_DIR, exist_ok=True)
            self._initialized = True
        except Exception:
            self._initialized = False

    def _load_sfx(self, name):
        """Load (generating if needed) an SFX into self._sounds[name]."""
        if not self._initialized:
            return
        try:
            path = get_sound_path(name)
            if os.path.exists(path):
                sound = pygame.mixer.Sound(path)
                sound.set_volume(self.sfx_volume)
                self._sounds[name] = sound
        except Exception:
            pass

    def play_sfx(self, name):
        """Play a sound effect by name. Generates/loads in background thread."""
        if not self.enabled or not self._initialized:
            return
        if name in self._sounds:
            try:
                self._sounds[name].play()
            except Exception:
                pass
            return

        def _bg():
            try:
                self._load_sfx(name)
                if name in self._sounds:
                    self._sounds[name].play()
            except Exception:
                pass

        threading.Thread(target=_bg, daemon=True).start()

    def play_music(self, style):
        """Play looping ambient music. Generates in background if needed."""
        if not self.music_enabled or not self._initialized:
            return
        if self._current_music == style:
            return

        def _bg():
            try:
                os.makedirs(SOUNDS_DIR, exist_ok=True)
                path = os.path.join(SOUNDS_DIR, f"music_{style}.wav")
                if not os.path.exists(path):
                    gen = _MUSIC_GENERATORS.get(style)
                    if gen:
                        samples = gen()
                        save_wav(samples, path)
                if os.path.exists(path):
                    pygame.mixer.music.load(path)
                    pygame.mixer.music.set_volume(self.music_volume)
                    pygame.mixer.music.play(-1)  # loop forever
                    self._current_music = style
            except Exception:
                pass

        self._current_music = style  # optimistic set to avoid re-trigger
        threading.Thread(target=_bg, daemon=True).start()

    def stop_music(self):
        """Fade out current music."""
        if not self._initialized:
            return
        try:
            pygame.mixer.music.fadeout(1000)
            self._current_music = None
        except Exception:
            pass

    def toggle_sfx(self):
        self.enabled = not self.enabled

    def toggle_music(self):
        self.music_enabled = not self.music_enabled
        if not self.music_enabled:
            self.stop_music()


# Global singleton
sound_manager = SoundManager()
