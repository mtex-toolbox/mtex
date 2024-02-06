function varargout = simulateGrains(this,varargin)
% generating 3d neper tessellations
%
% Syntax
%   
%   neper=neperInstance;
%   neper.filepath='C:\\Users\user\Work\Mtex\NeperExamples' %select working folder, default: @tempdir
%   numGrains = 100;
%   odf = unimodalODF(orientation.rand);
%   neper.simulateGrains(odf, numGrains)
%
%   ori=discreteSample(odf,numGrains)
%   neper.simulateGrains(ori)
%
% Input
%  neper      - @neperInstance
%  odf        - @SO3Fun
%  numGrains  - number of grains
%  ori        - @orientation
% 
% Output
%  allgrains.tess  - tessellation file, name specified at neper.filename3d, stored under neper.filepath
%  allgrains.ori   - orientation file, Euler-Bunge format,
%  ori_in.txt      - input orientations, rodrigues format

%change work directory
if this.newfolder==true
  try
    cd([this.filePath filesep this.folder]);
  catch
    cd(this.filePath);
    mkdir(this.folder);
    cd(this.folder);
  end
else
  cd(this.filePath);
end

%%
assert(nargin>1,'too few input arguments')
if nargin>=3  % odf & numGrains
  if isnumeric(varargin{2}) && isa(varargin{1},'SO3Fun')
    numGrains=varargin{2};
    ori = varargin{1}.discreteSample(numGrains);
  else
    error 'argument error'
  end
elseif nargin>=2 %ori
  if isa(varargin{1},'orientation')
    ori=varargin{1};
    numGrains=length(varargin{1});
  else
    error 'argument error'
  end 
end

% generate Neper symmetry names
CS = ori.CS.LaueName;
switch CS
  case '2/m11'
    CS='2/m';
  case '12/m1'
    CS='2/m';
  case '112/m'
    CS='2/m';
  case '-3m1'
    CS='-3m';
  case '-31m'
    CS='-3m';
  otherwise
end

% save ori to file
oriFilename='ori_in.txt';
fid=fopen(oriFilename,'w');
fprintf(fid,'%f %f %f\n',ori.Rodrigues.xyz.');
fclose(fid);

if check_option(varargin,'silent')
  output2file = ['>> ' this.filePath filesep 'neper.log'];
else
  output2file = '';
end
system([this.cmdPrefix 'neper -T -n ' num2str(numGrains) ...
  ' -id ' num2str(this.id) ' -morpho "' this.morpho '" ' ...
  ' -domain "cube(' num2str(this.cubeSize(1)) ',' num2str(this.cubeSize(2)) ',' num2str(this.cubeSize(3)) ')"' ...
  ' -morphooptistop "itermax=' num2str(this.iterMax) '" ' ... % decreasing the iterations makes things go a bit faster for testing
  ' -oricrysym "' CS '" '...
  ' -ori "file(' oriFilename ')" ' ... % read orientations from file, default rodrigues
  ' -statpoly faceeqs ' ... % some statistics on the faces
  ' -o ' this.fileName3d ' ' ... % output file name
  ' -oridescriptor rodrigues ' ... % orientation format in output file
  ' -oriformat plain ' ...
  ' -format tess,ori' ... % outputfiles
  output2file ...
  ' && ' ...
  ...
  this.cmdPrefix 'neper -V ' this.fileName3d '.tess' output2file]);

%% return value
if nargout >= 1
  varargout = {grain3d.load([this.fileName3d '.tess'],'CS',ori.CS)};
else
  varargout = {};
end

end