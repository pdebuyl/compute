import matplotlib
matplotlib.use('agg')
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt

N=3

def bit_component(x, i):
    """Return i-th bit of x"""
    return (x & 2**i) >> i

def bin_str(i):
    """Return a string representation of i with N bits."""
    out = ''
    for j in range(N-1,-1,-1):
        if (i>>j) & 1 == 1:
            out += '1'
        else:
            out += '0'
    return out

plt.rcParams['font.size'] = 18

fig = plt.figure(figsize=(6,5))
ax = fig.gca(projection='3d')

ax.plot(
    [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0],
    [1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1],
    [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1]
    )

for i in range(2**N):
    x = bit_component(i, 0)
    y = bit_component(i, 1)
    z = bit_component(i, 2)
    ax.text(x, y+0.05, z+0.05, bin_str(i))


ax.set_xticks([0,1])
ax.set_yticks([0,1])
ax.set_zticks([0,1])

ax.set_xlim3d(0, 1)
ax.set_ylim3d(0, 1)
ax.set_zlim3d(0, 1)

ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_zlabel('z')

ax.view_init(10, -67)

plt.savefig('binary_cube.png')
