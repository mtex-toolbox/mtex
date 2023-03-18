function grains = getSlice(this,varargin)
% generating 2d slices of 3d neper tesselations
%
% Syntax
%   
%   neper=neperInstance;
%   neper.simulateGrains(unimodalODF(orientation.rand), 100)
%
%   N=vector3d(1,1,1);   % normal vector of a plane
%   d=1;                 % d of plane equation
%   grains=neper.getSlice(N,d)
%
%   A=vector3d(1/3,1/3,1/3) %position vector of a point from the plane
%   grains=neper.getSlice(N,A)
%
% Input
%  N - slice normal @vector3d
%  d - d of a plane equation (a,b,c,d)
%  A - point in slice plane @vector3d
%
% Output
%  grains         - @grain2d
%  2dslice.tess   - 2d neper tesselation file, name specified at neper.fileName2d, stored under neper.filepath
%  2dslice.ori    - file with orientations in euler-bunge format

%%
%change work directory
if this.newfolder==true && exist(this.folder,'dir')==7
  cd([this.filePath this.folder]);
else
  cd(this.filePath)
end

%deleting old files, to make sure, to not load a wrong file, if slicing failed
if isfile('2dslice.tess')
  delete([this.fileName2d '.tess' ]);
end
if isfile('2dslice.ori')
  delete([this.fileName2d '.ori' ]);
end

%%
assert(nargin>1,'too few input arguments')
if nargin>2 && isa(varargin{1},'vector3d')
  n=varargin{1};
  if isa(varargin{2},"vector3d")
    d=dot(n,varargin{2});
  elseif isnumeric(varargin{2}) && isscalar(varargin{2})
    d=varargin{2};
  else
    error 'argument error'
  end
else
  error 'argument error'
end

%% get a slice
system([this.cmdPrefix 'neper -T -loadtess ' this.fileName3d '.tess ' ...
  '-transform "slice(' num2str(d) ',' num2str(n.x) ',' num2str(n.y) ',' num2str(n.z) ')" ' ... % this is (d,a,b,c) of a plane
  '-ori "file(' this.fileName3d '.ori)" ' ...
  '-o ' this.fileName2d ' ' ...
  '-oriformat geof ' ...
  '-oridescriptor rodrigues ' ...
  '-format tess,ori ' ...
  '&& ' ...
  ...
  this.cmdPrefix 'neper -V ' this.fileName2d '.tess']);

if ~isfile([this.fileName2d '.tess'])
  error 'slicing failed, try other plane parameters.'
end

grains = grain2d.load([this.fileName2d '.tess']);

end