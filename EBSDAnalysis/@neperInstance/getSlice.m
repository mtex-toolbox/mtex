function grains = getSlice(this,N,d,varargin)
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

% compute distance to origin
if isa(d,"vector3d"), d = dot(N,d); end

%deleting old files, to make sure, to not load a wrong file, if slicing failed
if isfile([this.filePath this.fileName2d '.tess' ]), delete([this.filePath this.fileName2d '.tess' ]); end
if isfile([this.filePath this.fileName2d '.ori' ]), delete([this.filePath this.fileName2d '.ori' ]); end

if check_option(varargin,'silent')
  output2file = ['>> ' this.filePath 'neper.log '];
else
  output2file = '';
end

% get a slice
system([this.cmdPrefix 'neper -T -loadtess ' this.filePathUnix this.fileName3d '.tess ' ...
  '-transform "slice(' num2str(d) ',' num2str(N.x) ',' num2str(N.y) ',' num2str(N.z) ')" ' ... % this is (d,a,b,c) of a plane
  ' ' num2str(this.varNeperopts) ' '... %add additional neper options, full syntax
  '-ori "file(' this.filePathUnix this.fileName3d '.ori)" ' ...
  '-o ' this.filePathUnix this.fileName2d ' ' ...
  '-oriformat geof ' ...
  '-oridescriptor rodrigues ' ...
  '-format tess,ori ' ...
  output2file ...
  '&& ' ...
  this.cmdPrefix 'neper -V ' this.filePathUnix this.fileName2d '.tess' output2file]);

if ~isfile([this.filePath this.fileName2d '.tess'])
  error 'slicing failed, try other plane parameters.'
end

grains = grain2d.load([this.filePath this.fileName2d '.tess']);

end
