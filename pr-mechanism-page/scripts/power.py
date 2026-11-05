"""How many judged samples does a comparison need? No data, Monte Carlo + Wilson interval.

python3 power.py --p0 0.85 --p1 0.75 --n 20 50 100 200 400 --judge 1.0 0.85
Prints, per judge accuracy, the chance a one-sided z-test (alpha 0.05) catches p0 -> p1 with n per side,
and the Wilson 95% interval around an observed p0 at each n. Fixed seed, 4,000 trials.
"""
import argparse, json, math, random

ap = argparse.ArgumentParser()
ap.add_argument("--p0", type=float, default=0.85); ap.add_argument("--p1", type=float, default=0.75)
ap.add_argument("--n", type=int, nargs="+", default=[20, 50, 100, 200, 400])
ap.add_argument("--judge", type=float, nargs="+", default=[1.0, 0.85])
ap.add_argument("--trials", type=int, default=4000); ap.add_argument("--seed", type=int, default=42)
a = ap.parse_args(); rng = random.Random(a.seed)


def detect(p0, p1, n, acc):
    obs = lambda p: p * acc + (1 - p) * (1 - acc)  # the judge flips a verdict with prob 1 - acc
    q0, q1, hits = obs(p0), obs(p1), 0
    for _ in range(a.trials):
        x = sum(rng.random() < q0 for _ in range(n)); y = sum(rng.random() < q1 for _ in range(n))
        pp = (x + y) / (2 * n); se = math.sqrt(max(pp * (1 - pp) * 2 / n, 1e-12))
        hits += (x / n - y / n) / se > 1.645
    return round(hits / a.trials, 3)


def wilson(k, n, z=1.96):
    p = k / n; d = 1 + z * z / n; c = p + z * z / (2 * n); h = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return [round((c - h) / d, 3), round((c + h) / d, 3)]


print(json.dumps({
    "p0": a.p0, "p1": a.p1, "n": a.n,
    "power": {str(j): [detect(a.p0, a.p1, n, j) for n in a.n] for j in a.judge},
    "wilson_at_p0": {n: wilson(round(a.p0 * n), n) for n in a.n},
}, indent=1))
