function grains = simulateTwinGrains(numGrains, mori, odf, bndA, varargin) 
% simulate a 3d twinning microstructure
%
% Syntax
%   
%   neper.init
%   numGrains = 100;
%   odf = unimodalODF(orientation.rand);
%   grains = neper.simulateTwinGrains(numGrains, mori, odf, bndA)
%
% Input
%  numGrains  - number of grains
%  mori - twinning orientation relationship
%  odf  - @SO3Fun
%  bndA - @S2Fun crystal boundary normal distribution
%  'silent'   - print log file, no console output
% 
% Output
%  grains - @grain3d
%

this = neper.instance;

% two stage tesselation: lamella normals from file

% take orientations from ODF
ori = discreteSample(odf,numGrains);

% compute twin boundary normals from host orientations
nA = ori .* bndA.discreteSample(numel(ori));

% write file with lamella normals, one line for each grain of the first tesselation
% the file should contain
% 1 x1 y1 z1
% 2 x2 y2 z2
% 3 x3 y3 z3
% 4 ...
% where x,y,z are specimen coordinates
d = [(1:length(nA)).',nA.xyz];
lamFile = [this.filePathUnix 'lamnormals.txt'];
fid = fopen(lamFile,'w');
fprintf(fid,"%d %f %f %f\n",d.');
fclose(fid);

aspectRatio = get_option(varargin,'aspectRatio','(1,1,1)');
lamellaWidth = get_option(varargin,'width',0.015);

if check_option(varargin,'silent')
  output2file = ['>> ' this.filePath 'neper.log'];
else
  output2file = '';
end

% simulate grains without macroscopic preferred normal direction
com  = [this.cmdPrefix ' neper -T -n ' num2str(numGrains) ...
  '::from_morpho -morpho "diameq:normal(10,1),aspratio' aspectRatio ...
  '::lamellar(w=' xnum2str(lamellaWidth) ',v=msfile(' lamFile '))"' ...
  ' -morphooptistop "iter=' num2str(this.iterMax) '"' ...
  ' -domain "cube(' num2str(this.cubeSize(1)) ',' num2str(this.cubeSize(2)) ',' num2str(this.cubeSize(3)) ')"' ...
  ' -o ' this.filePathUnix this.fileName3d output2file];

system(com);

grains = grain3d.load([this.filePathUnix this.fileName3d '.tess']);

% populate orientations

sep = zeros(1,numGrains+1);
l = 1;
Nxyz = grains.boundary.N.xyz;
I_GF = grains.I_GF;
nAxyz = nA(l).xyz;
for k = 1:length(grains)  
  progress(k,length(grains));  
  if all(abs(Nxyz(find(I_GF(k,:)),:) * nAxyz.') < cos(1e-3)) %#ok<FNDSB>
    l = l+1;
    sep(l) = k-1;
    nAxyz = nA(l).xyz;
  end
end
sep(end) = k;


oriAll = orientation.nan(length(grains),1,odf.CS);

for k = 1:length(sep)-1

  ind = sep(k)+1 : sep(k+1);

  oriAll(ind) = rotation.rand(length(ind),1,'maxAngle',2*degree) * ori(k);

  oriAll(ind(2:2:end)) = oriAll(ind(2:2:end)) .* mori;

end

grains.meanOrientation = oriAll;

% update boundary misorientations
gId = grains.boundary.grainId;
moriBND = orientation.nan(size(gId,1),1,odf.CS,odf.CS);
isNotBoundary = all(gId,2);
moriBND(isNotBoundary) = ...
  inv(grains.meanOrientation(gId(isNotBoundary,2))) ...
  .* grains.meanOrientation(gId(isNotBoundary,1));

grains.boundary.misrotation = moriBND;

end