import sys
import random
import math
from optparse import OptionParser

grains_nx = 2
grains_ny = 2
grains_xsize = 15
grains_ysize = 15
phases = 1
misorientation = 1.0

def create_lines(hexagonal):
    orientations = {}
    for x in range(grains_nx):
        for y in range(grains_ny):
            orientations[(x,y)] = (random.randrange(0.0, 90.0),
                                   random.randrange(0.0, 90.0),
                                   random.randrange(0.0, 90.0))

    lines = []
    lines += ['Channel Text File']
    lines += ['Prj\t%s' % 'testdata.ctf']
    lines += ['Author\t[Unknown]']
    lines += ['JobMode\tGrid']
    lines += ['XCells\t%i' % (grains_nx * grains_xsize,)]
    lines += ['YCells\t%i' % (grains_ny * grains_ysize,)]
    lines += ['XStep\t1']
    lines += ['YStep\t1']
    lines += ['AcqE1\t0']
    lines += ['AcqE2\t0']
    lines += ['AcqE3\t0']
    lines += ['Euler angles refer to Sample Coordinate system (CS0)!\tMag\t64\tCoverage\t100\tDevice\t0\tKV\t17\tTiltAngle\t70\tTiltAxis\t0']

    lines += ['Phases\t%i' % phases]
    for phase in range(phases):
        lines += ['9.541;17.74;5.295\t90;103.67;90\tGlaucophane\t2\t0\t0_5.0.9.1\t1477773286\t[Glaucophane.cry]']

    lines += ['Phase\tX\tY\tBands\tError\tEuler1\tEuler2\tEuler3\tMAD\tBC\tBS']

    for y in range(grains_ny * grains_ysize):
        ygrain = y / grains_ysize
        
        if hexagonal:
            if y % 2 != 0: 
                xpos = 0.5 
            else: 
                xpos = 0.0
            ypos = y * math.sqrt(3) / 2.0
        else:
            xpos = 0.0
            ypos = y

        for x in range(grains_nx * grains_xsize):
            xpos += 1
            xgrain = x / grains_xsize
            
            e1, e2, e3 = orientations[(xgrain, ygrain)]
            e1 += random.randrange(-misorientation*100.0, misorientation*100.0) / 100.0
            e2 += random.randrange(-misorientation*100.0, misorientation*100.0) / 100.0
            e3 += random.randrange(-misorientation*100.0, misorientation*100.0) / 100.0
            
            line = '%i\t%6.4f\t%6.4f\t%i\t%i\t%6.4f\t%6.4f\t%6.4f\t%i\t%i' % \
                (phase+1, xpos, ypos, 7, 0, e1, e2, e3, xgrain, ygrain)
            lines.append(line)
    
    return lines

parser = OptionParser()

parser.add_option('--hexagonal', dest='hexagonal', action='store_true',
                  help='Use hexagonal grid')
                  
(options, args) = parser.parse_args()

lines = create_lines(options.hexagonal)

filepath = args[0]
print 'Saving to %s' % filepath

with open(filepath, 'w') as fp:
    for line in lines:
        fp.write(line + '\r\n')
