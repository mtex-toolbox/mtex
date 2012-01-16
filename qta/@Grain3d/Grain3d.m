function grains = Grain3d(grainSet,ebsd)


grains = class(struct,'Grain3d',GrainSet(grainSet,ebsd));