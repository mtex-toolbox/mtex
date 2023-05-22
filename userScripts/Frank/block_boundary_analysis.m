% *********************************************************************
% Identify and plot block boundaries 
% (requires job object with calculated variant Ids)
% *********************************************************************
home; close all; clearvars -except job
%% Application - Determine Variant pairing
%Derive variant types 1 to 6 from variants 1 to 24
laths = job.transformedGrains;
laths.prop.variantType = laths.variantId - (laths.packetId-1) * max(job.variantId)/max(job.packetId);
%Get the boundary segments and neighbouring laths
lathboundaries = laths.boundary(job.csChild,job.csChild);
boundaryIds = lathboundaries.grainId;

[c,ia] = ismember(boundaryIds,laths.id);
boundaryIds(any(~c,2),:) = [];
lathboundaries(any(~c,2)) = [];
%Identify special boundaries, here V1-V2, V1-V3(V5), V1-V6 and V1-V4
%[S. Morito, A.H. Pham, T. Hayashi, T. Ohba, Mater. Today Proc. 2 (2015)
%S913–S916.]
varTypes = laths(laths.id2ind(boundaryIds)).variantType;
cond(1,:) = any(ismember(varTypes,1),2) & any(ismember(varTypes,2),2) | ...
            any(ismember(varTypes,3),2) & any(ismember(varTypes,4),2) | ...
            any(ismember(varTypes,5),2) & any(ismember(varTypes,6),2);     %V1-V2
cond(2,:) = any(ismember(varTypes,1),2) & any(ismember(varTypes,3),2) | ...
            any(ismember(varTypes,1),2) & any(ismember(varTypes,5),2) | ...
            any(ismember(varTypes,2),2) & any(ismember(varTypes,4),2) | ...
            any(ismember(varTypes,2),2) & any(ismember(varTypes,6),2) | ...
            any(ismember(varTypes,3),2) & any(ismember(varTypes,5),2) | ...
            any(ismember(varTypes,4),2) & any(ismember(varTypes,6),2);     %V1-V3(V5)
cond(3,:) = any(ismember(varTypes,1),2) & any(ismember(varTypes,6),2) | ...
            any(ismember(varTypes,2),2) & any(ismember(varTypes,3),2) | ...
            any(ismember(varTypes,4),2) & any(ismember(varTypes,5),2);     %V1-V6
cond(4,:) = any(ismember(varTypes,1),2) & any(ismember(varTypes,4),2) | ...
            any(ismember(varTypes,2),2) & any(ismember(varTypes,5),2) | ...
            any(ismember(varTypes,3),2) & any(ismember(varTypes,6),2);     %V1-V4
        
%% Application - Plot a map of variant pairing
%Plot the boundaries 
colors = {'r','g','b','k'};
ebsdC = job.ebsdPrior;
try data = ebsdC.bc; catch data = ebsdC.imagequality; end
figure; plot(ebsdC,data);
setColorRange([mean(data)-2*std(data),mean(data)+2*std(data)])
mtexColorMap black2white
hold on
labelstr = {'V1-V2','V1-V3(V5)','V1-V6','V1-V4'};
for i = 1:size(cond,1)     
    plot(lathboundaries(cond(i,:)),'linewidth',2,'linecolor',colors{i},'DisplayName',labelstr{i});
end
legend

%% Application - Plot the fractions of variant pairing
%Plot bar diagram to show the special boundary fractions
for i = 1:size(cond,1)    
    frac(i) = sum(lathboundaries(cond(i,:)).segLength)/sum(lathboundaries(any(cond)).segLength);
end
figure;
bar(categorical(labelstr),frac,'r');
ylabel('Fraction of block boundaries')


