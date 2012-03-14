%% Merging Grains
% 
%% Open in Editor
%
%% Contents
%
%%
% Let us start with some reconstructed grains

mtexdata aachen
grains = calcGrains(ebsd,'angle',2*degree)


%% Merging Grains
% <GrainSet.merge.html merge>, here we merge grains with misorientation
% angle between 0 and 15 degree.

[merged_grains,I_PC] = merge(grains,[0 15]*degree);

%%
% the first output are the merged grains as a new GrainSet.

merged_grains

%%
% the seconed output argument |I_PC| is an incidence matrix betreen parent
% grains and child grains. i.e. a row indicates child, and a colum his
% parent, if there is an entry.

spy(I_PC)
xlabel('child (index)'), ylabel('parent (index)')

%%
% e.g. 

I_PC(1000,:)

%%
% would say, the parent grain nr. 1000 has 2 childs, where the index
% referres to the grain nr. of the |grains| object.

parent = merged_grains(1000);
close, plot(parent)

%%
% So, we can select the childs by

childs = grains(find(I_PC(1000,:)))

close, plot(childs)

%%
% With the selected child grains, we can easily do some grain statistics

area(childs)'./area(parent)

%%
% Or compute the length of the common boundary

(sum(perimeter(childs)) - perimeter(parent))/2

%%
% the two populations of the EBSD of the neighbored grains are close
% together

close,   plotpdf(get(childs(1),'EBSD'),Miller(1,1,1),'marker','x','markersize',5,'antipodal')
hold on, plotpdf(get(childs(2),'EBSD'),Miller(1,1,1),'marker','x','markersize',5,'antipodal')

%%
% Since a row of a matrix has a 1 if a merged grain has a child, we can
% just sum up the row entries and get the child count. moreover 

histc(full(sum(I_PC,2)),1:12)'

%%
% shows the number of childs in total, i.e. how many grains were merged how
% often. first entry indicates, that there was no merge; the second entry,
% that there two grains merged, and so on.
%
%%
% actually, we can merge again

[merged_grains_20,I_PC2] = merge(merged_grains,[10 20]*degree);

histc(full(sum(I_PC2,2)),1:12)'

%%
% then multipication 

I_PC2 * I_PC;

%%
% of the incidence matrices would show us, which merged grains are the
% grandparents of the grains. Now we are going to plot it

close,   plot(merged_grains_20,'property',double(sum(I_PC2,2)>1),'translucent',.3)
hold on, plot(merged_grains,   'property',double(sum(I_PC,2)>1),'translucent',.3)
hold on,   plotBoundary(grains,'color',[.7 .7 .7])

%% Merging grains with special boundaries
% We can also merge grains with a special grain boundary relation, this
% might be useful, if we want to arrange our grains logically in a hierarchy

[merged_grains,I_PC] = merge(grains,CSL(3));

%%
% Some grains show, that they form a complex, i.e. there are some merges

histc(full(sum(I_PC,2)),1:12)'

%%
% Let us just select such a merged parent grain and its childs

% identify the index of merged grains
% find(sum(I_PC,2)>1)

parent = merged_grains(1064)
childs = grains(find(I_PC(1064,:)))

%%
% We can inspect the orientations

close,   plotpdf(get(childs(1),'EBSD'),Miller(0,0,1),...
  'markercolor','g','marker','x','markersize',2,'antipodal')
hold on, plotpdf(get(childs(2),'EBSD'),Miller(0,0,1),...
  'markercolor','b','marker','x','markersize',2)
hold on, plotpdf(get(childs(3),'EBSD'),Miller(0,0,1),...
  'markercolor','m','marker','x','markersize',2)

%%
% or plot them spatially together with their special boundary

close,   plot(childs(3),'facecolor','m')
hold on, plot(childs(2),'facecolor','b')
hold on, plot(childs(1),'facecolor','g')

hold on, plotBoundary(childs,'property',CSL(3),...
  'linewidth',3,'color','r')
hold on, plotBoundary(parent,'linewidth',2,'color','k')
axis tight
