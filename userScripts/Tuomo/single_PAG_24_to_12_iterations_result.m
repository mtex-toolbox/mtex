
clear
close all

plotx2east

load martensite_single_grain

[grains,ebsd('indexed').grainId] =...
    calcGrains(ebsd('indexed'),'angle',3*degree);

cond_grains = ismember(grains.id,unique(ebsd(ids_of_interest).grainId));


%%
job = parentGrainReconstructor(ebsd,grains) % define job
job.useBoundaryOrientations = true;
clearvars grains ebsd

job.p2c = orientation.KurdjumovSachs(job.p2c.CS,job.p2c.SS);
job.calcParent2Child('quantile',0.6,'c2c'); % get representative OR

%%
job.calcHyperGraph3('threshold',5*degree,'c2c','mergeSimilar','mergethreshold',8*degree,'keepGraph')

numIters = [3 10 50];
grainId = 1844;

%%

for k = 1:length(numIters);
    if k == 1
    job.clusterHyperGraph3('numIter',numIters(k),...
        'inflationPower',1,'merged','mergethreshold',8*degree,'keepGraph')
        graphplotfunc(job,cond_grains,grainId,k,numIters)
    else
    job.clusterHyperGraph3('numIter',numIters(k) - numIters(k-1),...
        'inflationPower',1,'merged','mergethreshold',8*degree,'keepGraph')
        graphplotfunc(job,cond_grains,grainId,k,numIters)
    end
end

for k = 1:length(numIters);
    if k == 1
    job.clusterHyperGraph3('numIter',numIters(k),...
        'inflationPower',1.05,'merged','mergethreshold',8*degree,'keepGraph')
        graphplotfunc(job,cond_grains,grainId,k,numIters)
    else
    job.clusterHyperGraph3('numIter',numIters(k) - numIters(k-1),...
        'inflationPower',1.05,'merged','mergethreshold',8*degree,'keepGraph')
        graphplotfunc(job,cond_grains,grainId,k,numIters)
    end
end

%%
function graphplotfunc(job,cond_grains,grainId,k,numIters)
p2c = orientation.NishiyamaWassermann(job.p2c.CS,job.p2c.SS);
p2c = p2c.project2FundamentalRegion(job.p2c);

pOri = variants(p2c, job.grains.meanOrientation, job.votes.parentId(:,1));

nextAxis
plot(job.grains(cond_grains),...
    pOri(cond_grains))
lims = job.ebsd.extent;
xlim([lims(1) lims(2)])
ylim([lims(3) lims(4)])

text(lims(1)+5,lims(4)-10, [num2str(numIters(k)) ' iterations'],...
    'HorizontalAlignment','left',...
    'FontSize',20, 'FontWeight','bold','BackgroundColor', 'white')

end
