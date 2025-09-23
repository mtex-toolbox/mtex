function varargout = simulateGrains(varargin)
% generating 3d neper tessellations
%
% Syntax
%   
%   neper.init
%   neper.filepath='C:\Users\user\Work\Mtex\NeperExamples' %select working folder, default: @tempdir
%   numGrains = 100;
%   odf = unimodalODF(orientation.rand);
%   grains = neper.simulateGrains(numGrains, odf)
%
%   ori = discreteSample(odf,numGrains)
%   grains = neper.simulateGrains(ori,'silent')
%
% Input
%  numGrains - number of grains
%  odf       - @SO3Fun
%  ori       - @orientation
%  'silent'  - print log file, no console output
% 
% Output
%  grains - @grain3d
%


this = neper.instance;

assert(nargin>0,'too few input arguments')

if isnumeric(varargin{1})
  numGrains = varargin{1};
  ori = varargin{2}.discreteSample(numGrains);
else
  ori=varargin{1};
  numGrains=length(varargin{1});
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
fid=fopen([this.filePath oriFilename],'w');
fprintf(fid,'%f %f %f\n',ori.Rodrigues.xyz.');
fclose(fid);

if check_option(varargin,'silent')
  output2file = ['>> ' this.filePath 'neper.log'];
else
  output2file = '';
end
system([this.cmdPrefix 'neper -T -n ' num2str(numGrains) ...
  ' -id ' num2str(this.id) ' -morpho "' this.morpho '" ' ...
  ' -domain "cube(' num2str(this.cubeSize(1)) ',' num2str(this.cubeSize(2)) ',' num2str(this.cubeSize(3)) ')"' ...
  ' -morphooptistop "itermax=' num2str(this.iterMax) '" ' ... % decreasing the iterations makes things go a bit faster for testing
  ' ' num2str(this.varNeperopts) ' '... %add additional neper options, full syntax
  ' -oricrysym "' CS '" '...
  ' -ori "file(' [this.filePathUnix oriFilename] ')" ' ... % read orientations from file, default rodrigues
  ' -statpoly faceeqs ' ... % some statistics on the faces
  ' -o ' [this.filePathUnix this.fileName3d] ' ' ... % output file name
  ' -oridescriptor rodrigues ' ... % orientation format in output file
  ' -oriformat plain ' ...
  ' -format tess,ori' ... % outputfiles
  output2file ...
  ' && ' ...
  ...
  this.cmdPrefix 'neper -V ' [this.filePathUnix this.fileName3d] '.tess' output2file]);

%% return value
if nargout >= 1
  varargout = {grain3d.load([this.filePath this.fileName3d '.tess'],'CS',ori.CS)};
else
  varargout = {};
end

end
