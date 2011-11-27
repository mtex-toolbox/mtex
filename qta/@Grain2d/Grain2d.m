function grains = Grain2d(grainSet,ebsd)


grains = class(struct,'Grain2d',GrainSet(grainSet,ebsd));