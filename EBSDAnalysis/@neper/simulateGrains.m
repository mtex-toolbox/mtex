function grains = simulateGrains(numGrains, varargin)
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
  ' -statpoly faceeqs ' ... % some statistics on the faces
  ' -o ' [this.filePathUnix this.fileName3d] ' ' ... % output file name
  ' -format tess' ... % outputfiles
  output2file ...
  ' && ' ...
  ...
  this.cmdPrefix 'neper -V ' [this.filePathUnix this.fileName3d] '.tess' output2file]);

grains = grain3d.load([this.filePath this.fileName3d '.tess']);


% set orientations
if ~isa(varargin{1},'orientation')
  ori = varargin{1}.discreteSample(length(grains)); % if neper regularization is used, length(grains) might be different from numGrains
else
  ori=varargin{1};
end

grains.CSList{2} =ori.CS;
grains.meanOrientation = ori;

end
