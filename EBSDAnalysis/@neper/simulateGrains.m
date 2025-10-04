function grains = simulateGrains(ori,varargin)
% generating 3d neper tessellations
%
% Syntax
%   
%   initNeper
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

if isnumeric(ori)
  numGrains = ori;
  ori = varargin{1}.discreteSample(numGrains);
else
  numGrains=length(ori);
end

if check_option(varargin,'silent')
  screenOutput = ['>> ' this.filePath 'neper.log'];
else
  screenOutput = '';
end

morpho = char(this.morpho);
if check_option(varargin,'aspectRatio')
  morpho = [morpho,',aspratio (' ...
    xnum2str(get_option(varargin,'aspectRatio'),'delimiter',',') ')'];
end

com  = [this.cmdPrefix ' neper -T -n ' num2str(numGrains) ...
  ' -morpho "' morpho '"' ...
  ' -morphooptistop "iter=' num2str(this.iterMax) '"' ...
  ' -domain "' char(this.geometry) '"' ...
  ' -o ' this.filePathUnix this.fileName3d screenOutput];

system(com);

grains = grain3d.load([this.filePath this.fileName3d '.tess'],'CS',ori.CS);

% set the grain orientations
grains.meanOrientation = ori;

end
