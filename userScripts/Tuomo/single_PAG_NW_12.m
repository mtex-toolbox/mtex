
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

job.p2c = orientation.NishiyamaWassermann(job.p2c.CS,job.p2c.SS);

%%
job.calcHyperGraph2('threshold',5*degree,'c2c')

numIters = [0 1 3 10 50];
grainId = 4691;

%
for k = 1:length(numIters)
    if k == 1
        job.clusterHyperGraph2('numIter',numIters(k),'inflationPower',1,'keepGraph')
        graphplotfunc(job,cond_grains,grainId,k,numIters)
    else
        job.clusterHyperGraph2('numIter',numIters(k) - numIters(k-1),'inflationPower',1,'keepGraph')
        graphplotfunc(job,cond_grains,grainId,k,numIters)
    end
end

%%

job.calcParentFromVote;
nextAxis
plot(job.grains(cond_grains & job.grains.phase == 2),...
    job.grains(cond_grains & job.grains.phase == 2).meanOrientation)
lims = job.ebsd.extent;
xlim([lims(1) lims(2)])
ylim([lims(3) lims(4)])

function graphplotfunc(job,cond_grains,grainId,k,numIters)

numV = length(variants(job.p2c,'parent'));

[i,j] = find(tril(job.graph));
i1 = ceil(i/numV);
i2 = i-(i1-1)*numV;
j1 = ceil(j/numV);
j2 = j-(j1-1)*numV;
prob = nonzeros(tril(job.graph));

cond = i1 ~= j1;

i1 = i1(cond);
j1 = j1(cond);

cond2 = (i1 == grainId | j1 == grainId);
i1 = i1(cond2);
j1 = j1(cond2);

i2 = i2(cond);
j2 = j2(cond);

i2 = i2(cond2);
j2 = j2(cond2);

prob = prob(cond);
prob = prob(cond2);

pOri = variants(job.p2c, job.grains(j1).meanOrientation, j2);
ipfKey = ipfHSVKey(job.csParent);
colors = ipfKey.orientation2color(pOri);

%%
%Equivalency:
z = unique([i1;j1]);
ord = zeros(max(z),1);
ord(z) = 1:length(z);

[x,y] = centroid(job.grains);
G = graph(ord(i1),ord(j1),prob);

if k == 1
    newMtexFigure('layout',[2,3])
else
    nextAxis
end

plot(job.grains(cond_grains).boundary)
hold on
plot(job.grains(unique([i1;j1])).boundary,'linecolor','red')
hold on
plot(G,'XData',x(unique([i1;j1])),'YData',y(unique([i1;j1])),...
    'EdgeColor',colors,'NodeColor','none','NodeLabel',{})
hold on
lims = job.ebsd.extent;
text(lims(2)-40,lims(3)+15, {[num2str(numIters(k)) ' iterations'],...
    [num2str(length(z)) ' nodes'],...
    [num2str(length(i1)) ' edges']}, 'HorizontalAlignment','left',...
    'FontSize',20, 'FontWeight','bold','BackgroundColor', 'white')

xlim([lims(1) lims(2)])
ylim([lims(3) lims(4)])

end
