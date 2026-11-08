"""feature-space figure of the notIndexed parts, from the csv files niParts writes"""
import csv, sys
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

src, out = sys.argv[1], sys.argv[2]
maps = ['peridotite', 'forsterite', '1C_1']
style = {'crack': ('#d91a1a', '^'), 'void': ('#333333', 's'),
         'pore': ('#1a59e6', 'o'), 'pocket': ('#f29900', 'D')}

def load(n):
    r = list(csv.DictReader(open(f'{src}/{n}.csv')))
    d = {k: np.array([x[k] for x in r]) for k in r[0]}
    for k in d:
        if k != 'class':
            d[k] = d[k].astype(float)
    d['w'] = 2 * d['rMax'] - 1
    d['lam'] = d['feret'] / d['w']
    return d

data = {n: load(n) for n in maps}
pool = {k: np.concatenate([data[n][k][data[n]['isThick'] > 0] for n in maps])
        for k in ['w', 'lam', 'area', 'oriShare1', 'rim1', 'class']}

plt.rcParams.update({'font.size': 10, 'axes.spines.top': False, 'axes.spines.right': False,
                     'axes.edgecolor': '#888', 'axes.grid': True, 'grid.color': '#e6e6e6'})
fig, ax = plt.subplots(2, 2, figsize=(11, 9))

# (a) share of the notIndexed area in parts up to a width
a = ax[0, 0]
for n, c in zip(maps, ['#555', '#1a59e6', '#d91a1a']):
    d = data[n]
    o = np.argsort(d['w'])
    a.step(d['w'][o], np.cumsum(d['area'][o]) / d['area'].sum(), where='post', color=c, lw=2, label=n)
a.axvline(2 * 3.1, color='#999', ls='--', lw=1)
a.text(6.4, 0.05, 'default alpha 3.1\nfills width < 6.2', color='#666', fontsize=9)
a.set_xscale('log'); a.set_xlabel('part width 2·r_max − 1 (pixels)')
a.set_ylabel('share of notIndexed pixels in parts this narrow')
a.set_title('(a) notIndexed area by part width', loc='left')
a.legend(frameon=False, loc='center right')

def scatter(a, x, y, keep):
    for k, (c, m) in style.items():
        s = keep & (pool['class'] == k)
        a.scatter(x[s], y[s], s=12 + 2 * np.sqrt(pool['area'][s]), c=c, marker=m,
                  edgecolors='white', linewidths=0.8, label=f'{k} ({s.sum()})', zorder=3)

# (b) width against elongation
a = ax[0, 1]
scatter(a, pool['w'], pool['lam'], np.ones(len(pool['w']), bool))
a.axhline(4, color='#999', ls='--', lw=1)
a.set_xscale('log'); a.set_yscale('log')
a.set_xlabel('part width (pixels)'); a.set_ylabel('elongation: max Feret diameter / width')
a.set_title('(b) thick parts: width and elongation', loc='left')
a.legend(frameon=False, loc='upper left')

# (c) elongation against rim orientation share
a = ax[1, 0]
scatter(a, pool['oriShare1'], pool['lam'], np.ones(len(pool['w']), bool))
a.axvline(0.85, color='#999', ls='--', lw=1)
a.set_yscale('log')
a.set_xlabel('share of the rim held by one orientation (10°)')
a.set_ylabel('elongation')
a.set_title('(c) thick parts: rim orientation and elongation', loc='left')

# (d) two-pass against single-pass rim share
a = ax[1, 1]
keep = ~np.isnan(pool['rim1'])
scatter(a, pool['oriShare1'], pool['rim1'], keep)
a.plot([0, 1], [0, 1], color='#999', lw=1)
a.axvline(0.85, color='#ccc', ls='--', lw=1); a.axhline(0.85, color='#ccc', ls='--', lw=1)
a.set_xlabel('rim share from small-alpha grains (two passes)')
a.set_ylabel('rim share from rim pixels alone (one pass)')
a.set_title('(d) peridotite + forsterite: one pass vs two', loc='left')

from matplotlib.ticker import ScalarFormatter, NullFormatter
for a in ax.flat:
    for axis in (a.xaxis, a.yaxis):
        if axis.get_scale() == 'log':
            axis.set_major_formatter(ScalarFormatter()); axis.set_minor_formatter(NullFormatter())
ax[0, 1].set_yticks([1.5, 2, 3, 4, 6, 8]); ax[1, 0].set_yticks([1.5, 2, 3, 4, 6, 8])
ax[0, 1].set_xticks([5, 7, 10, 15, 20, 30]); ax[0, 0].set_xticks([1, 2, 3, 5, 10, 20, 30])
fig.tight_layout()
fig.savefig(out, dpi=110)
