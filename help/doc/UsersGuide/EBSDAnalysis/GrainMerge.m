%% Merging Grains
% Reorganize grains by merging special boundaries. 
% 
%% Open in Editor
%
%% Contents
%
%% Merging Grains
% The command <GrainSet.merge.html merge> merges grains, whos boundary
% segments were classified by <GrainSet.specialBoundary.html
% specialBoundary>. In that way, all special boundaries which were plotted via 
% <GrainSet.plotBoundary.html plotBoundary> could be considered as
% boundaries, which should merge grains.
%%
% Let us start with some reconstructed grains with grain boundaries of
% at least 2 degree difference in orientation.

mtexdata aachen
plotx2east
grains = calcGrains(ebsd,'angle',2*degree)

%%
% Now, let us merge grains for which the orientation difference lies
% between 0 and 15 degree

[merged_grains,I_PC] = merge(grains,[0 15]*degree);

%%
% the first output a set of merged grains as a new @GrainSet.

merged_grains

%%
% the second output argument |I_PC| is an incidence matrix of parent
% grains versus child grains, i.e. a row indicates parents, and a column
% its childs, if there is an entry.

spy(I_PC)
xlabel('child (index)'), ylabel('parent (index)')

%%
% Since a row of a matrix has a 1 if a merged grain has a child, we can
% just sum up the row entries and get the child count, i.e. if there is
% only one 1 in a row than there is only one child and the grain was
% actually unchanged.

child_count = full(sum(I_PC,2));

hist(child_count,1:11)

%%
% we can get the index of certain childs by indexing a row

I_PC(1000,:)

%%
% would say, the parent grain nr. 1000 has 2 childs, where the index
% refers to the grain nr. of the intial |grain| object. 
% We can select the child grains by logical indexing

parent = merged_grains( 1000 );
childs = grains(logical( I_PC(1000,:) ))

close all
plot(childs)
hold on
plotBoundary(childs,'linecolor','r','linewidth',1.5)
plotBoundary(parent,'linecolor','k','linewidth',2)

%%
% the two populations of the EBSD of the neighbour grains are close
% together

close all
plotpdf(childs(1).ebsd,Miller(1,1,1),...
  'marker','x','markersize',5,'antipodal')
hold on
plotpdf(childs(2).ebsd,Miller(1,1,1),...
  'marker','x','markersize',5,'antipodal')

%%
% Sometimes, one is interessed in a hierarchy grains. So we would merge again

[merged_grains_20,I_PC2] = merge(merged_grains,[10 20]*degree);

close all
hist(full(sum(I_PC2,2)),1:11)

%%
% then multipication 

I_PC2 * I_PC;

%%
% of the incidence matrices would show us, which merged grains are the
% grandparents of the grains. Now we are going to plot it

child_count_20 = sum(I_PC2,2);
child_count_20>1;
s = 738;

grandparent  = merged_grains_20(s)
parents      = merged_grains( logical(I_PC2(s,:)))
childs       = grains( logical( I_PC2(s,:) * I_PC ) )

close all
plot(childs)
hold on
plotBoundary(parents,'linecolor','r','linewidth',2)
plotBoundary(grandparent,'linecolor','k','linewidth',2)

%%

close all
plot(parents)
hold on
plotBoundary(grandparent,'linecolor','k','linewidth',2)

%%

close all
plot(grandparent)

%% Merging grains with special boundaries
% We can also merge grains with a special grain boundary relation, this
% might be useful if we want to arrange our grains logically in a certain hierarchy

[merged_grains,I_PC] = merge(grains,CSL(3));

%%
% Some grains show that they form a complex interaction, i.e. there are some merges
% and some do not merge

close all
hist(full(sum(I_PC,2)),1:12)

%%
% Let us just select such a merged parent grain and its child grains

% identify the index of merged grains
% find(sum(I_PC,2)>1)

parent = merged_grains(1258)
childs = grains(find(I_PC(1258,:)))

%%
% We can inspect the orientations

close all
plotpdf(parent.ebsd,Miller(0,0,1),'antipodal');
hold on

c = {'y','m','r','c','g'};
for k=1:numel(childs)
  plotpdf(childs(k).ebsd,Miller(0,0,1),...
    'markercolor',c{k},'marker','x','markersize',5,'antipodal')
end

%%
% or plot them spatially together with their special boundary

c = {'y','m','r','c','g'};

close all
plotBoundary(parent,'linewidth',3)
hold on

plotBoundary(childs,'property',CSL(3),...
  'linecolor','b','linewidth',2)

plotBoundary(childs,'property',CSL(9),...
  'linecolor',[ 0 1 1 ],'linewidth',3)

for k=1:numel(childs)
  plot(childs(k),'facecolor',c{k},'edgecolor','none')
end
