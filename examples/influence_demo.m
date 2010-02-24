%% MTEX - Influence of Threshold angle
%
%
% 
% 

%% Specify Crystal and Specimen Symmetry

% specify crystal and specimen symmetry
CS = {...
  symmetry('m-3m'),... % crystal symmetry phase 1
  symmetry('m-3m')};   % crystal symmetry phase 2
SS = symmetry('-1');   % specimen symmetry

%% Import ebsd data

fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],'Bunge');

plotx2east

%% Segmentation
% perform a regionalisation with different threshold angels

angles = [2.5:2.5:20 25:5:45];
grains = cell(size(angles));

for k=1:numel(angles)
  [grains{k} ebsd] = segment2d(ebsd,'angle', angles(k)*degree,'silent');
end
 
%% grain size distribution

bin = exp(1:0.5:6);
cell2mat(cellfun(@(x) hist(grainsize(x),bin), grains,'uniformoutput',false)')'

%% Estimate ODF with different threshold angles

kern = kernel('de la Vallee Poussin','halfwidth',7*degree);

for k=1:numel(angles)  
  %misorientation to neighbour
  mis2m_ebsd = misorientation(grains{k},ebsd);
  mis2m_odf{k}  = calcODF(mis2m_ebsd(1),'kernel',kern,'exact','silent');
   
  %misorientation to mean
  mis2n_ebsd = misorientation(grains{k});
  mis2n_odf{k}  = calcODF(mis2n_ebsd(1),'kernel',kern,'exact','silent');
end


%% Calculate Texture-properties: index and entroy

%% 
% preallocation of some variables
tindex_n = zeros(size(angles));
tindex_m = zeros(size(angles));
tentropy_m = zeros(size(angles));
tentropy_n = zeros(size(angles));

%%
% now we evaluate the misorientation odfs of every threshold 

S3 = SO3Grid(5*degree,symmetry('m-3m'),symmetry);

for k=1:numel(angles)
 tindex_n(k)   = textureindex(mis2n_odf{k},'SO3Grid',S3);
 tentropy_n(k) = entropy(mis2n_odf{k},'SO3Grid',S3);
 tindex_m(k)   = textureindex(mis2m_odf{k},'SO3Grid',S3);
 tentropy_m(k) = entropy(mis2m_odf{k},'SO3Grid',S3);
end

%%
% and plot it

figure('position',[50 50 900 300])

subplot('position',[0.1 0.15 0.25 0.8])
semilogy(angles, [tindex_n;tindex_m ],'.-')
grid on, ylabel('textureindex'),xlabel('threshold angle in�')

subplot('position',[0.45 0.15 0.25 0.8])
semilogy(angles,[tentropy_n;tentropy_m ],'.-')
grid on ,ylabel('entropy'),xlabel('threshold angle in�')

legend('misorientation to neighbour','misorientation to mean','Location','BestOutside')

