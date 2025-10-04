function grains = simulateTwinGrains(numGrains, mori, odf, bndA, varargin) 
% simulate a 3d twinning microstructure
%
% Syntax
%   
%   initNeper
%   numGrains = 100;
%   odf = unimodalODF(orientation.rand);
%   grains = neper.simulateTwinGrains(numGrains, mori, odf, bndA)
%
% Input
%  numGrains  - number of grains
%  mori - twinning orientation relationship
%  odf  - @SO3Fun
%  bndA - @S2Fun crystal boundary normal distribution
%  'silent' - print log file, no console output
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
lamellaWidth = get_option(varargin,'width',(prod(this.cubeSize) / numGrains)^(1/3)/4);

if check_option(varargin,'silent')
  output2file = ['>> ' this.filePath 'neper.log'];
else
  output2file = '';
end

morpho = char(this.morpho);
if check_option(varargin,'aspectRatio')
  morpho = [morpho,',aspratio (' ...
    xnum2str(get_option(varargin,'aspectRatio'),'delimiter',',') ')'];
end

%diameq:normal(10,1),aspratio' aspectRatio

% simulate grains without macroscopic preferred normal direction
com  = [this.cmdPrefix ' neper -T -n ' num2str(numGrains) ...
  '::from_morpho -morpho "' morpho ...
  '::lamellar(w=' xnum2str(lamellaWidth) ',v=msfile(' lamFile '))"' ...
  ' -morphooptistop "iter=' num2str(this.iterMax) '"' ...
  ' -domain "' char(this.geometry) '"' ...
  ' -o ' this.filePathUnix this.fileName3d output2file];

system(com);

grains = grain3d.load([this.filePathUnix this.fileName3d '.tess']);

% determine number of twins for each host grain
numTwins = zeros(1,numGrains);
l = 1; k = 1; 
dk = 50; % chunksize for efficient searching should be larger than actual number of childs
Nxyz = grains.boundary.N.xyz;
nAxyz = nA.xyz;
I_GF = grains.I_GF;

while k <= numel(grains)  
  progress(k,length(grains));

  dk = min(dk,size(I_GF,1)-k+1);
  [Gid,Fid] = find(I_GF(k:k+dk-1,:));
  isPlane = abs(Nxyz(Fid,:) * nAxyz(l,:).') < cos(1e-3);
  
  pos = find(accumarray(Gid,isPlane,[dk,1],@all),1);
  
  if isempty(pos)
    numTwins(l) = dk;
    break
  else
    numTwins(l) = pos;
    k = k + pos;
    l = l+1;    
  end
end

% the parent ids
hostId = repelem(1:numGrains,numTwins);

% define twinned orientations
ori = rotation.rand(length(grains),1,'maxAngle',2*degree) .* ori(hostId);
ori(2:2:end) = ori(2:2:end) .* mori;
grains.meanOrientation =  ori;

% update boundary misorientations
gId = grains.boundary.grainId;
moriBND = orientation.nan(size(gId,1),1,odf.CS,odf.CS);
isNotBoundary = all(gId,2);
moriBND(isNotBoundary) = ...
  inv(grains.meanOrientation(gId(isNotBoundary,2))) ...
  .* grains.meanOrientation(gId(isNotBoundary,1));

grains.boundary.misrotation = moriBND;

end