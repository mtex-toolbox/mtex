# the stored benchmark maps of pymtex-grainBenchmark as MATLAB v5 .mat files, pixels in MATLAB's
# column-major order of a [ny nx] grid (y fastest)
import json, os, sys
import numpy as np, scipy.io as sio
G = "/home/hielscher/mtex/pymtex-grainBenchmark/bench"
sys.path.insert(0, os.path.join(G, "grains"))
import measure, tiers

OUT = sys.argv[1]
NAMES = ["T1_clean_cracks", "T1_noisy_cracks", "T1_deformed_cracks", "T1_clean_matrix", "T1_noisy_matrix", "T1_clean_patchy",
         "T1_noisy_patchy", "T1_patchyD21", "T1_clean_clusters", "T1_noisy_clusters", "T1_clean_boundaryNotIndexed", "T0_07_clusters"]
lines = []
for name in NAMES:
  tier = name[:2]
  r = measure.read(os.path.join(G, "out", "grains", tier), name)
  h = r["head"]
  nx, ny, kind = h["grid"]["nx"], h["grid"]["ny"], h["grid"]["kind"]
  col = lambda v: np.asarray(v).reshape(ny, nx, *np.shape(v)[1:]).swapaxes(0, 1).reshape(nx * ny, *np.shape(v)[1:])
  q = col(r["q"])
  ok = ~np.isnan(q).any(axis=1)
  names = list(r["phases"])
  P = [measure.PHASES[p] for p in names]
  label = col(r["label"]).astype(float)
  sio.savemat(os.path.join(OUT, name + ".mat"), dict(
    name=name, tier=tier, gridType=kind, gridSize=np.array([[ny, nx]], float), step=float(h["grid"].get("step", 1.0)),
    x=col(r["pos"][:, 0])[:, None], y=col(r["pos"][:, 1])[:, None], isIndexed=ok[:, None],
    quat=q, quatOrder="a b c d, scalar first; NaN where notIndexed",
    phaseId=col(r["phase"]).astype(float)[:, None], phaseNames=np.array(names, dtype=object),
    pointGroup=np.array([p[0] for p in P], dtype=object), latticeABC=np.array([p[1] for p in P], float),
    latticeAngles=np.array([p[2] for p in P], float), alignment=np.array([p[3] for p in P], dtype=object),
    trueGrainId=label[:, None], calcGrainsAngle=5.0, minPixel=5.0, spec=json.dumps(h)), do_compression=True)
  ng = len(np.unique(label[label > 0]))
  lines.append(f"| {name} | {ny}x{nx} | {kind} | {100 * (1 - ok.mean()):.1f} % | {ng} | {', '.join(f'{n} ({p[0]})' for n, p in zip(names, P))} |")
  print(lines[-1])
open(os.path.join(OUT, "table.tmp"), "w").write("\n".join(lines) + "\n")
