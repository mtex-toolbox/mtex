function grains = simulateChildGrains(numParents, p2c, varargin) 
% simulate a 3d microstructure after martensitic phase transformation
%
% Syntax
%   
%   neper.init
%   numGrains = 100;
%   odf = unimodalODF(orientation.rand);
%   grains = neper.simulateChildGrains(numGrains, p2c, odfParent, habitPlane)
%
% Input
%  numGrains  - number of grains
%  p2c - parent to child OR
%  odfParent  - @SO3Fun
%  habitPlane - @Miller
%  'silent'   - print log file, no console output
% 
% Output
%  grains - @grain3d
%

this = neper.instance;

if isscalar(p2c), p2c = p2c.variants(1:6).'; end

% take parent orientations from parent ODF
odfParent = getClass(varargin,'SO3Fun');
oriP = discreteSample(odfParent,numParents);

% habit plane
habitPlane = getClass(varargin,'Miller',Miller(1,1,1,p2c.CS));

% compute habit planes from parent orientations
nA = oriP .* habitPlane.normalize;

% write to file
lamFile = [this.filePathUnix 'lamnormals.txt'];
fid = fopen(lamFile,'w');
fprintf(fid,"%d %f %f %f\n",[(1:length(nA)).',nA.xyz].');
fclose(fid);

aspectRatio = get_option(varargin,'aspectRatio','(1,1,1)');
lamellaWidth = get_option(varargin,'width',0.015);

if check_option(varargin,'silent')
  output2file = ['>> ' this.filePath 'neper.log'];
else
  output2file = '';
end

% simulate grains without macroscopic preferred normal direction
com  = [this.cmdPrefix ' neper -T -n ' num2str(numParents) ...
  '::from_morpho -morpho "diameq:normal(10,1),aspratio' aspectRatio ...
  '::lamellar(w=' xnum2str(lamellaWidth) ',v=msfile(' lamFile '))"' ...
  ' -morphooptistop "iter=' num2str(this.iterMax) '"' ...
  ' -domain "cube(' num2str(this.cubeSize(1)) ',' num2str(this.cubeSize(2)) ',' num2str(this.cubeSize(3)) ')"' ...
  ' -o ' this.filePathUnix this.fileName3d output2file];

system(com);

grains = grain3d.load([this.filePathUnix this.fileName3d '.tess']);

% [Gid,Fid] = find(I_GF(1:30,:));
% d = abs(Nxyz(Fid,:) * nAxyz.')<cos(1e-3);
% accumarray(Gid,d,[30,1],@all)

% determine number of child grains for each parent
numChilds = zeros(1,numParents);
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
    numChilds(l) = dk;
    break
  else
    numChilds(l) = pos;
    k = k + pos;
    l = l+1;    
  end
end

% the parent ids
pId = repelem(1:numParents,numChilds);

% draw random variant id such that subsequent ids are different
N = numel(p2c);
vId = zeros(length(grains),1,'uint32');
vId(1) = randi(N);
for k = 2:length(grains)
  r = randi(N-1);
  vId(k) = r + (r >= vId(k-1));
end
vId(k-1) = double(vId(k-1));

% define child orientations
grains.meanOrientation = rotation.rand(length(grains),1,'maxAngle',2*degree) ...
  .* oriP(pId) .* inv(p2c(vId));

% update boundary misorientations
gId = grains.boundary.grainId;
moriBND = orientation.nan(size(gId,1),1,p2c.SS,p2c.SS);
isNotBoundary = all(gId,2);
moriBND(isNotBoundary) = ...
  inv(grains.meanOrientation(gId(isNotBoundary,2))) ...
  .* grains.meanOrientation(gId(isNotBoundary,1));

grains.boundary.misrotation = moriBND;

end