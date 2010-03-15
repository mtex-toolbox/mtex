%% MTEX - Influence of Threshold angle
%
%
% 
% 

%% Specify Crystal and Specimen Symmetry

% specify crystal and specimen symmetry
CS = symmetry('m-3m');
SS = symmetry('-1'); 

%% Import ebsd data

fname = [mtexDataPath '/aachen_ebsd/85_829grad_07_09_06.txt'];

ebsd = loadEBSD(fname,CS,SS,'interface','generic',...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC'},...
  'Columns', [2 3 4 5 6 7 8 9],'Bunge');

plotx2east

%% Estimate ODF with different threshold angles
% Calculate Texture-properties: index and entroy

angles = [5 10 15 20 30 45];

kern = kernel('de la Vallee Poussin','halfwidth',7*degree);
S3 = SO3Grid(7.5*degree,CS,CS); % predefine an SO3 discretisation 

for k=1:numel(angles)  
  
  % perform a regionalisation with different threshold angels
  [grains ebsdt] = segment2d(ebsd,'angle', angles(k)*degree,'silent');
  
  %misorientation to neighbour
  mis2m_odf  = calcODF(misorientation(link(grains,ebsdt(1))),...
    'kernel',kern,'silent','SO3Grid',S3);
   
  %misorientation to mean
  mis2n_odf  = calcODF(misorientation(grains,ebsdt(1)),...
    'kernel',kern,'silent','SO3Grid',S3);  
  
  tindex_n(k)   = textureindex(mis2n_odf,'SO3Grid',S3);
  tentropy_n(k) = entropy(mis2n_odf,'SO3Grid',S3);
  tindex_m(k)   = textureindex(mis2m_odf,'SO3Grid',S3);
  tentropy_m(k) = entropy(mis2m_odf,'SO3Grid',S3);
  
end


%%
% and plot it

figure('position',[50 50 900 300])

subplot('position',[0.1 0.15 0.25 0.8])
semilogy(angles, [tindex_n;tindex_m ],'.-')
grid on, ylabel('textureindex'),xlabel('threshold angle in degree')

subplot('position',[0.45 0.15 0.25 0.8])
semilogy(angles,[tentropy_n;tentropy_m ],'.-')
grid on ,ylabel('entropy'),xlabel('threshold angle in degree')

legend('misorientation to neighbour','misorientation to mean','Location','BestOutside')

