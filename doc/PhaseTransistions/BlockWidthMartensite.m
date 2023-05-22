%% Block width in martensite
%
%% 
% MTEX reconstructs grains from EBSD orientation maps. In the case of
% martensite formed in low-carbon steels, these grains are in literature
% often called "blocks", with each block containing two types of
% martensitic variants with a low mutual misorientation angle. The variants
% in a block form side by side into a stack of thin laths so that on the
% image plane, the block typically has a clearly distinguishable long axis
% and a short axis. "Block width" is the width of the stack of laths in the
% block, NOT the length of the short axis of the block on the image plane.
% The stack of laths that makes up the block forms approximately on the
% particular {111} plane in austenite that is parallel to the (011) plane
% in martensite.
%
% The new prior austenite reconstruction features allow us to easily
% determine the specific {111} type plane in austenite parallel to the
% (011) plane in martensite. Following reconstruction, the trace and normal
% of this specific {111} plane can be plotted for visual verification.
%
% Let's reconstruct and plot one austenite grain from the example dataset:

% plotting convention
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');

% load the data
mtexdata martensite;

ebsd('Iron fcc').rotations = quaternion.nan;
ebsd('Iron fcc').phase = 0;

%%

% extract fcc and bcc symmetries
csBCC = ebsd.CSList{2}; % austenite bcc:
csFCC = ebsd.CSList{3}; % martensite fcc:

% grain reconstruction
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);

% remove small grains
ebsd(grains(grains.grainSize < 3)).rotations = quaternion.nan;
ebsd(grains(grains.grainSize < 3)).phase = 0;
ebsd(grains(grains.grainSize < 3)).grainId = 0;

% reidentify grains with small grains removed:
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);
%
% initial guess is Kurdjumov Sachs
KS = orientation.KurdjumovSachs(csFCC,csBCC);

% get neighbouring grain pairs
grainPairs = grains.neighbors;

% compute an optimal parent to child orientation relationship
[fcc2bcc, fit] = calcParent2Child(grains(grainPairs).meanOrientation,KS);

%%

% compute the probabilities
threshold = 2*degree;
tol = 1.5*degree;
prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));

% the corresponding similarity matrix
A = sparse(grainPairs(:,1),grainPairs(:,2),prob,length(grains),length(grains));
p = 1.6; % inflation power:
A = mclComponents(A,p);

% merge grains according to the adjecency matrix A
[parentGrains, parentId] = merge(grains,A);

% ensure grainId in parentEBSD is set up correctly with parentGrains
parentEBSD = ebsd;
parentEBSD('indexed').grainId = parentId(ebsd('indexed').grainId);

% the measured child orientations
childOri = grains('Iron bcc').meanOrientation;

% the parent orientation we are going to compute
parentOri = orientation.nan(max(parentId),1,fcc2bcc.CS);
fit = inf(size(parentOri));
weights = grains('Iron bcc').grainSize;

% loop through all parent grains
for k = 1:max(parentId)
  if nnz(parentId==k) > 1
    % compute the parent orientation from the child orientations
    [parentOri(k),fit(k)] = calcParent(childOri(parentId==k), fcc2bcc,'weights',weights((parentId==k)));
  end
end

% update mean orientation of the parent grains
parentGrains(fit<5*degree).meanOrientation = parentOri(fit<5*degree);
parentGrains = parentGrains.update;

% consider only austenite pixels that now belong to martensite grains
isNowFCC = parentGrains.phaseId(max(1,parentEBSD.grainId)) == 3 & parentEBSD.phaseId == 2;

% compute parent orientation
[parentEBSD(isNowFCC).orientations, fit] = calcParent(ebsd(isNowFCC).orientations,...
  parentGrains(parentEBSD(isNowFCC).grainId).meanOrientation,fcc2bcc);

% merge grains with similar orientation
[parentGrains, mergeId] = merge(parentGrains,'threshold',10*degree);
parentEBSD('indexed').grainId = mergeId(parentEBSD('indexed').grainId);

%%
% With the prior austenite orientations generated, we may now compute the
% packetId and determine the {111} to (011) parallelisms from that:

% compute variantId and packetId
[variantId,packetId] = calcChildVariant(parentOri(parentId),childOri,fcc2bcc);

% associate to each packet id a color and plot
color = ind2color(packetId);

% Get all 111 vector3ds for each grain:
h = Miller({1,1,1},{1,-1,1},{-1,1,1},{1,1,-1},fcc2bcc.CS);
z = parentOri(parentId).project2FundamentalRegion*h;
% Turn packetIds into linear indexing:
zz = sub2ind(size(z),[1:length(packetId)]',packetId);
% Pick the {111}a vectors with (011)m parallelism
zzz = z(zz);

%%
% We may then pick a single prior austenite grain and inspect whether there
% is any apparent coincidence between morphology and {111}a || (011)m
% planes:

% Pick a single grain
ids_step_1 = find(mergeId == 832);
ids_single_grain = find(ismember(parentId,ids_step_1));

%Plot the direction normal to and the trace of 111 plane on
%each grain grain.
plot(grains(ids_single_grain))
hold on
quiver(grains(ids_single_grain),cross(zzz(ids_single_grain),zvector),'linecolor','r');
quiver(grains(ids_single_grain),zzz(ids_single_grain),'linecolor','r');

%%
% The figure shows that the long axis of each block indeed appears to be
% parallel to a particular {111} plane. In cases where it is not so, it
% appears that the {111} plane in question is close to parallel to the
% image plane.
% 
% To calculate block width, we will need some sort of representative value
% for the width perpendicular to the image plane. We can use
% <grain2d.caliper.html |caliper|> to get the maximum width in a given
% direction.
%
% Caliper requires an angular value for direction. We may use the azimuthal
% angle of the {111} plane normals we determined previously:

% omega for caliper:
omega = zzz.rho;

% Do arrayfun on caliper so you can supply a corresponding omega for each grain:
A = arrayfun(@(x,y) caliper(x,y),grains,omega);

%%
% When given a direction, caliper gives a value rather than a vector. We
% may change this value to a vector to plot with quiver:

% Make vectors for plotting with quiver:
A_vec = rotate(cross(zzz,zvector),rotation.byAxisAngle(zvector,90*degree));
A_vec = normalize(A_vec).*A/2;
A_vec.antipodal = 1;

%%
% Using the caliper value, we can calculate values for block widths.
% Following <https://doi.org/10.1016/j.msea.2005.12.048 Morito et al.>, we should multiply
% the caliper value with the sine of the angle between the chosen {111}
% plane normal and the image plane normal. The angle corresponds to the
% inclination angle (theta) of the chosen {111} plane normal:

%Calculate assumed block width:
d_block = A.*sin(zzz.theta);

%%
% We can visually verify our calculations by drawing the caliper values on
% the grains. They should correspond to the morphology of the grain in the
% perpendicular direction to the {111} plane normal.

%Plot to color each grain with the assumed block width and show the caliper vector on
%the grain, as well as direction normal to and the trace of 111 plane on
%the grain.
figure
plot(grains(ids_single_grain),d_block(ids_single_grain))
hold on
ha(1) = quiver(grains(ids_single_grain),cross(zzz(ids_single_grain),zvector),'linecolor','r');
ha(2) = quiver(grains(ids_single_grain),zzz(ids_single_grain),'linecolor','r');
ha(3) = quiver(grains(ids_single_grain),A_vec(ids_single_grain),'noScaling');
legend(ha,'trace of 111a || 011m','normal of 111a || 011m','caliper on image plane')

%%
% Looking at the figure, the maximum projection value given by caliper
% might give an unrepresentatively high value in some cases. We can look at
% a histogram of the calculated block widths and calculate the mean:

figure
histogram(d_block,'Normalization','probability')
title(['Mean block width = ' num2str(round(mean(d_block(~isnan(d_block))),2)) ' \mum'])
xlabel('Block width [\mum]')
ylabel('Fraction of grains')

%%
% According to <https://doi.org/10.1016/j.msea.2005.12.048 Morito et al.>, we could expect
% a block width value somewhere between 1 and 2 um. Another way to get a
% representative value for block width calculation might be to project all
% boundary points to the vector perpendicular to the trace of the {111}
% plane. Using the function found at the bottom of this page:
[p,px,py] = projectPoints2Vector(grains,rotate(cross(zzz,zvector),rotation.byAxisAngle(zvector,90*degree)));

%%
% The projections on the line for a single grain are shown in the figure
% below. The histogram below it shows how for an approximate lath shape,
% the result looks like a bimodal distribution of projections:
close all

figure
plot(grains(3111))
hold on
V = grains{3111}.V;
poly = grains{3111}.poly;
ce = grains{3111}.centroid;
Vg = V(poly{1},:);
plot([(px{3111}+ce(1))';Vg(:,1)'],[(py{3111}+ce(2))';Vg(:,2)'])
legend('off')

figure
histogram(p{3111},20)
xlabel('Projection length [\mum]')

%%
% A representative value for something like the average halfwidth could be the
% mean of the absolute values:

new_A = cellfun(@abs,p,'UniformOutput',false);
new_A = cellfun(@mean,new_A);
%Vector form for visual verification:
new_A_vec = rotate(cross(zzz,zvector),rotation.byAxisAngle(zvector,90*degree));
new_A_vec = normalize(new_A_vec).*new_A';
new_A_vec.antipodal = 1;

%%
% We may now calculate the block widths again and plot to visually verify
% what the width perpendicular to the {111} trace looks like:

%Calculate assumed block width:
d_block_new = 2*new_A'.*sin(zzz.theta);

figure
plot(grains(ids_single_grain),d_block_new(ids_single_grain))
hold on
ha(1) = quiver(grains(ids_single_grain),cross(zzz(ids_single_grain),zvector),'linecolor','r');
ha(2) = quiver(grains(ids_single_grain),zzz(ids_single_grain),'linecolor','r');
ha(3) = quiver(grains(ids_single_grain),new_A_vec(ids_single_grain),'noScaling');
legend(ha,'trace of 111a || 011m','normal of 111a || 011m','Mean of projected points')

%%
% The histogram and the figure shows that the block width is consistently a
% little smaller calculated this way.

figure
histogram(d_block_new,100,'Normalization','probability')
title(['Mean block width = ' num2str(round(mean(d_block_new(~isnan(d_block_new))),2)) ' \mum'])
xlabel('Block width [\mum]')
ylabel('Fraction of grains')

%%
% The new value is more in line with the studies of
% <https://doi.org/10.1016/j.msea.2005.12.048 Morito et al.>
