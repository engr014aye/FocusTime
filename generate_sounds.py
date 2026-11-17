import wave
import math
import struct
import random
import os

OUT_DIR = r"D:\Antigravity\Qadir Apps\FocusTime\assets\sounds"
os.makedirs(OUT_DIR, exist_ok=True)

SAMPLE_RATE = 44100

def write_wav(filename, samples_left, samples_right):
    filepath = os.path.join(OUT_DIR, filename)
    with wave.open(filepath, 'w') as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for l, r in zip(samples_left, samples_right):
            # Clamp to 16-bit signed range
            il = int(max(-32767, min(32767, l * 32767)))
            ir = int(max(-32767, min(32767, r * 32767)))
            frames.extend(struct.pack('<hh', il, ir))
        wf.writeframes(frames)
    size_mb = os.path.getsize(filepath) / (1024 * 1024)
    print(f"Generated {filename}: {size_mb:.2f} MB")

def gen_rain(duration_sec=32):
    n_samples = int(SAMPLE_RATE * duration_sec)
    left = [0.0] * n_samples
    right = [0.0] * n_samples
    
    # Pink noise base with random drops and gentle rumble
    b0_l, b1_l, b2_l = 0.0, 0.0, 0.0
    b0_r, b1_r, b2_r = 0.0, 0.0, 0.0
    
    for i in range(n_samples):
        # White noise input
        wl = random.uniform(-1.0, 1.0)
        wr = random.uniform(-1.0, 1.0)
        
        # Pink noise filter approximation
        b0_l = 0.99765 * b0_l + wl * 0.0990460
        b1_l = 0.96300 * b1_l + wl * 0.1160400
        b2_l = 0.57000 * b2_l + wl * 0.2222300
        pink_l = (b0_l + b1_l + b2_l) * 0.12
        
        b0_r = 0.99765 * b0_r + wr * 0.0990460
        b1_r = 0.96300 * b1_r + wr * 0.1160400
        b2_r = 0.57000 * b2_r + wr * 0.2222300
        pink_r = (b0_r + b1_r + b2_r) * 0.12
        
        # Low frequency gentle rumble
        t = i / SAMPLE_RATE
        rumble = math.sin(2 * math.pi * 55 * t) * 0.04 + math.sin(2 * math.pi * 42 * t) * 0.03
        
        # Occasional drops
        drop_l = 0.0
        drop_r = 0.0
        if random.random() < 0.008:
            drop_l = random.uniform(0.1, 0.35)
        if random.random() < 0.008:
            drop_r = random.uniform(0.1, 0.35)
            
        left[i] = pink_l * 0.65 + rumble + drop_l
        right[i] = pink_r * 0.65 + rumble + drop_r
        
    write_wav("rain.wav", left, right)

def gen_forest(duration_sec=32):
    n_samples = int(SAMPLE_RATE * duration_sec)
    left = [0.0] * n_samples
    right = [0.0] * n_samples
    
    # Wind rustle
    b_l, b_r = 0.0, 0.0
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        wind_mod = (math.sin(2 * math.pi * 0.12 * t) * 0.5 + 0.5) ** 1.5
        wl = random.uniform(-1, 1)
        wr = random.uniform(-1, 1)
        b_l = 0.95 * b_l + 0.05 * wl
        b_r = 0.95 * b_r + 0.05 * wr
        
        base_l = b_l * 0.25 * wind_mod
        base_r = b_r * 0.25 * wind_mod
        
        # Harmonious bird calls
        bird = 0.0
        # Periodic bird patterns
        cycle_t = t % 6.0
        if 1.0 < cycle_t < 1.4:
            f = 2400 + 400 * math.sin(2 * math.pi * 12 * (cycle_t - 1.0))
            bird = math.sin(2 * math.pi * f * t) * 0.18 * math.sin(math.pi * (cycle_t - 1.0) / 0.4)
        elif 3.2 < cycle_t < 3.7:
            f = 2800 + 350 * math.cos(2 * math.pi * 15 * (cycle_t - 3.2))
            bird = math.sin(2 * math.pi * f * t) * 0.15 * math.sin(math.pi * (cycle_t - 3.2) / 0.5)
            
        left[i] = base_l + bird * 0.7
        right[i] = base_r + bird * 0.4
        
    write_wav("forest.wav", left, right)

def gen_ocean(duration_sec=32):
    n_samples = int(SAMPLE_RATE * duration_sec)
    left = [0.0] * n_samples
    right = [0.0] * n_samples
    
    b_l, b_r = 0.0, 0.0
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        # 12-second wave swell
        swell = ((math.sin(2 * math.pi * (1/11.0) * t - math.pi/2) + 1.0) / 2.0) ** 2.2
        wl = random.uniform(-1, 1)
        wr = random.uniform(-1, 1)
        
        # Dynamic low pass filter modulated by swell
        alpha = 0.04 + 0.12 * swell
        b_l = (1 - alpha) * b_l + alpha * wl
        b_r = (1 - alpha) * b_r + alpha * wr
        
        sub = math.sin(2 * math.pi * 38 * t) * 0.08 * swell
        
        left[i] = (b_l * 0.65 * swell) + sub
        right[i] = (b_r * 0.65 * swell) + sub
        
    write_wav("ocean_waves.wav", left, right)

def gen_binaural_alpha(duration_sec=32):
    # Left 210Hz, Right 220Hz -> 10Hz Alpha beat (calm, focused flow state)
    n_samples = int(SAMPLE_RATE * duration_sec)
    left = [0.0] * n_samples
    right = [0.0] * n_samples
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        # Left channel fundamental + gentle harmonics
        sl = (math.sin(2 * math.pi * 210.0 * t) * 0.35 +
              math.sin(2 * math.pi * 105.0 * t) * 0.18 +
              math.sin(2 * math.pi * 420.0 * t) * 0.06)
        # Right channel (binaural 10Hz offset)
        sr = (math.sin(2 * math.pi * 220.0 * t) * 0.35 +
              math.sin(2 * math.pi * 110.0 * t) * 0.18 +
              math.sin(2 * math.pi * 440.0 * t) * 0.06)
        
        # Soft ambient warm pad breathing modulation
        warm_mod = 0.85 + 0.15 * math.sin(2 * math.pi * 0.1 * t)
        left[i] = sl * warm_mod
        right[i] = sr * warm_mod
        
    write_wav("binaural_alpha.wav", left, right)

def gen_white_noise(duration_sec=24):
    n_samples = int(SAMPLE_RATE * duration_sec)
    left = [0.0] * n_samples
    right = [0.0] * n_samples
    
    b_l, b_r = 0.0, 0.0
    for i in range(n_samples):
        # Soft brown/pink focus noise
        wl = random.uniform(-1, 1)
        wr = random.uniform(-1, 1)
        b_l = 0.92 * b_l + 0.08 * wl
        b_r = 0.92 * b_r + 0.08 * wr
        left[i] = b_l * 0.4
        right[i] = b_r * 0.4
        
    write_wav("white_noise.wav", left, right)

def gen_zen_bell(duration_sec=8):
    # Rich Tibetan Singing Bowl chime (432Hz with shimmering harmonics and long exponential decay)
    n_samples = int(SAMPLE_RATE * duration_sec)
    left = [0.0] * n_samples
    right = [0.0] * n_samples
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        decay = math.exp(-0.75 * t)
        
        # Shimmering beat frequency
        f1 = 432.0
        f2 = 435.5
        f3 = 864.0
        f4 = 1296.0
        f_sub = 216.0
        
        sig = (math.sin(2 * math.pi * f1 * t) * 0.35 +
               math.sin(2 * math.pi * f2 * t) * 0.25 +
               math.sin(2 * math.pi * f3 * t) * 0.15 * math.exp(-1.2 * t) +
               math.sin(2 * math.pi * f4 * t) * 0.08 * math.exp(-2.0 * t) +
               math.sin(2 * math.pi * f_sub * t) * 0.18 * decay)
               
        left[i] = sig * decay
        right[i] = sig * decay
        
    write_wav("zen_bell.wav", left, right)

def gen_completion_chime(duration_sec=5):
    # Uplifting 4-note celebration arpeggio (C5: 523.25, E5: 659.25, G5: 783.99, C6: 1046.50)
    n_samples = int(SAMPLE_RATE * duration_sec)
    left = [0.0] * n_samples
    right = [0.0] * n_samples
    
    notes = [
        (0.0, 523.25),
        (0.22, 659.25),
        (0.44, 783.99),
        (0.66, 1046.50),
    ]
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        sig = 0.0
        for start_t, freq in notes:
            if t >= start_t:
                dt = t - start_t
                env = math.exp(-1.8 * dt)
                sig += (math.sin(2 * math.pi * freq * dt) * 0.3 +
                        math.sin(2 * math.pi * (freq * 2) * dt) * 0.12 * math.exp(-3.0 * dt)) * env
                        
        left[i] = sig * 0.75
        right[i] = sig * 0.75
        
    write_wav("completion_chime.wav", left, right)

def gen_click(duration_sec=0.25):
    n_samples = int(SAMPLE_RATE * duration_sec)
    left = [0.0] * n_samples
    right = [0.0] * n_samples
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-40.0 * t)
        sig = math.sin(2 * math.pi * 1200 * t) * env * 0.5
        left[i] = sig
        right[i] = sig
        
    write_wav("click_tick.wav", left, right)

if __name__ == "__main__":
    print("Generating rich soundscape assets...")
    gen_rain(34)
    gen_forest(34)
    gen_ocean(34)
    gen_binaural_alpha(34)
    gen_white_noise(25)
    gen_zen_bell(8)
    gen_completion_chime(5)
    gen_click(0.3)
    print("Done!")
