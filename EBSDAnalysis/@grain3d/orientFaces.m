function grains = orientFaces(grains)
% that up grain.I_GF such that +/- 1 indicates outgoing/ingoing normals
%
% Syntax
%  grains = grains.orientFaces
%
% Description 
%
% This functions requires the free and open source GPTToolbox
% https://de.mathworks.com/matlabcentral/fileexchange/49692-gptoolbox>
% to be installed.

try
  gptoolbox_version
catch ME
  error(['For this function you need the have the free ' ...
    '<a href="https://de.mathworks.com/matlabcentral/fileexchange/49692-gptoolbox">' ...
    'GPTToolbox</a> to be installed'])
end

addpath(strjoin(strcat('~/mtex/gptoolbox/',{'external','imageprocessing', 'images', 'matrix', 'mesh', 'mex', 'quat','utility','wrappers'}),':'))

I_GF = grains.I_GF;
F = grains.F;
V = grains.V.xyz;

for k = 1:size(I_GF,1)
  progress(k,size(I_GF,1))
  fk = find(I_GF(k,:));
  if numel(fk) < 1, continue; end
  Fk  = F(fk,:);

  [FFk, Ck] = bfs_orient(Fk);     % libigl: BFS orient :contentReference[oaicite:4]{index=4}
  [FFk_out, I_flip] = orient_outward(V, FFk, Ck);

  same = all(FFk_out == Fk, 2);
  sgn  = ones(numel(fk),1); 
  sgn(~same) = -1;

  I_GF(k, fk) = sgn;

end

grains.I_GF = I_GF;

end

function test
gId = 3;
plot(grains(gId),'micronbar','off')
hold on
quiver3(grains(gId).boundary.centroid,grains(gId).I_GF.' .* grains(gId).boundary.N)
hold off
end