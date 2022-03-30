
% *********************************************************************
%    Workflow for reconstruction involving variant refinement
% *********************************************************************
home; close all; clear variables;
currentFolder;
startup_mtex;
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');
setMTEXpref('FontSize',14)   
ebsd = mtexdata('martensite');
%% Compute, filter and smooth grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',2*degree);
ebsd(grains(grains.grainSize < 3)) = [];
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',2*degree);
grains = smooth(grains,5);
%% Define and refine parent-to-child orientation relationship
job_temp = parentGrainReconstructor(ebsd,grains);
job_temp.p2c = orientation.GreningerTrojano(job_temp.csParent, job_temp.csChild);
job_temp.calcParent2Child;
%% Reconstruct parent microstructure and plot the results
job_temp.calcHyperGraph3('threshold',5*degree,'c2c','mergeSimilar','mergethreshold',8*degree,'keepGraph');
job_temp.clusterHyperGraph3('numIter',20,'inflationPower',1,'merged','mergethreshold',8*degree,'keepGraph');
job_temp.calcParentFromVote;
figure;
plot(job_temp.parentGrains,job_temp.parentGrains.meanOrientation,'linewidth',2);
%% Calculate variants and reconstruct new grains based on variants
job_temp.calcVariants;
ebsdC = job_temp.ebsdPrior(job_temp.grainsPrior(job_temp.isTransformed));
oriP = job_temp.grains(job_temp.mergeId(ebsdC.grainId)).meanOrientation;
[varIds,packIds] = calcVariantId(oriP,ebsdC.orientations,job_temp.p2c,...
                                 'variantMap', job_temp.variantMap);
varPids = [varIds,job_temp.grains(job_temp.mergeId(ebsdC.grainId)).id];
[laths,ebsdC.grainId] = calcGrains(ebsdC,'variants',varPids);
laths(ebsdC.grainId).prop.packetId = packIds;
%% Redo the reconstruction with refined child grains
job = parentGrainReconstructor(ebsdC,laths);
job.p2c = orientation.GreningerTrojano(job_temp.csParent, job_temp.csChild);
job.calcParent2Child;
%% Reconstruct parent microstructure and plot the results
job.calcHyperGraph3('threshold',5*degree,'c2c','mergeSimilar','mergethreshold',8*degree,'keepGraph');
job.clusterHyperGraph3('numIter',20,'inflationPower',1,'merged','mergethreshold',8*degree,'keepGraph');
job.calcParentFromVote;
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2);
%% Clean reconstructed grains
job.mergeSimilar('threshold',7.5*degree);
job.mergeInclusions('maxSize',150);
figure;
plot(job.parentGrains,job.parentGrains.meanOrientation,'linewidth',2)
%% Variant analysis
job_temp.calcVariants;
plotMap_variants(job,'linewidth',3);
plotMap_packets(job,'linewidth',3);
