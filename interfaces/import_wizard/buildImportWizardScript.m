function str = buildImportWizardScript(ebsd,filePath,mapConvention,eulerConvention,dataSet,plotMask,phaseNames)
% build the reproducible import script emitted by import_wizard
%
% Syntax
%   str = buildImportWizardScript(ebsd,filePath,mapConvention,eulerConvention)
%   str = buildImportWizardScript(...,dataSet,plotMask,phaseNames)
%
% Input
%  ebsd            - configured @EBSD data
%  filePath        - source file
%  mapConvention   - selected map @plottingConvention
%  eulerConvention - selected Euler @plottingConvention
%  dataSet         - selected HDF5 data set number
%  plotMask        - phases enabled in the wizard
%  phaseNames      - mineral names displayed in the phase table

if nargin < 5, dataSet = []; end
if nargin < 6, plotMask = true(1,numel(ebsd.CSList)); end
if nargin < 7, phaseNames = []; end

templatePath = fullfile(mtex_path,'templates','import','loadEBSDtemplate.m');
str = fileread(templatePath);

% phases
lines = cell(1,numel(ebsd.CSList));
for k = 1:numel(lines)
  lines{k} = phaseLiteral(ebsd.CSList(k),phaseName(ebsd,phaseNames,k));
end
block = ['[' newline strjoin(lines,[', ...' newline]) newline ']'];
str = strrep(str,'{crystal symmetry}',block);

% plotting convention
str = strrep(str,'{plottingConvention}', ...
  plottingConventionLiteral(mapConvention));

% source file
[pathStr,baseName,extStr] = fileparts(char(filePath));
str = strrep(str,'{path to files}',charLiteral(pathStr));
str = strrep(str,'{file names}', ...
  sprintf('[pname filesep %s]',charLiteral([baseName extStr])));

% loader options
if ~isempty(dataSet)
  str = strrep(str,'{options}',sprintf('''dataSet'',%d',dataSet));
else
  str = strrep(str,',{options}','');
end

% Euler correction
correction = sprintf('rotation.map(%s,%s,%s,%s)', ...
  vectorLiteral(eulerConvention.east),vectorLiteral(mapConvention.east), ...
  vectorLiteral(eulerConvention.outOfScreen),vectorLiteral(mapConvention.outOfScreen));
str = strrep(str,'{eulerCorrection}',correction);

% first plot
str = strrep(str,'{sanityPlot}', ...
  sanityPlotLiteral(ebsd,plotMask,phaseNames));

end

% =========================================================================
function str = phaseLiteral(cs,name)

name = char(name);
color = colorLiteral(cs.color);

if isa(cs,'notIndexed') || ischar(cs)
  if strcmpi(name,'notIndexed') && isempty(color)
    str = '  notIndexed()';
  elseif isempty(color)
    str = ['  notIndexed(' charLiteral(name) ')'];
  else
    str = ['  notIndexed(' charLiteral(name) ', ' color ')'];
  end
  return
end

lattice = {charLiteral(char(cs.pointGroup)),latticeLiteral(cs.abc)};

if hasFreeAngles(cs.lattice)
  lattice{end+1} = [latticeLiteral(cs.abg / degree) ' * degree'];
end

% what a reader looks for is the mineral name, and a lattice read from an
% HDF5 file is long enough to push it off the screen - so it starts a line
opts = {'''mineral''',charLiteral(name)};
if ~isempty(color), opts = [opts, {'''color''',color}]; end

% preserve the crystal frame edited in the Alignment column
align = alignment(cs);
for k = 1:numel(align)
  opts{end+1} = charLiteral(align{k}); %#ok<AGROW>
end

str = ['  crystalSymmetry(' strjoin(lattice,', ') ', ...' newline ...
  '    ' strjoin(opts,', ') ')'];

end

% =========================================================================
function name = phaseName(ebsd,phaseNames,k)

if isempty(phaseNames) || numel(phaseNames) < k
  name = ebsd.CSList(k).mineral;
elseif iscell(phaseNames)
  name = phaseNames{k};
else
  name = phaseNames(k);
end
name = char(name);

end

% =========================================================================
function str = colorLiteral(color)

str = '';
if ischar(color) || (isstring(color) && isscalar(color))
  str = charLiteral(char(color));
  return
end
if ~isnumeric(color) || numel(color) ~= 3 || ~all(isfinite(color))
  return
end
color = double(color(:)).';

% a name says what the color is, an RGB triplet does not - so use one
% whenever the palette str2rgb reads has this very color
try
  palette = getMTEXpref('colorPalette','CSS');
  [name,rgb] = colornames(palette,color);
  if max(abs(rgb - color)) < 1e-6
    str = charLiteral(name{1});
    return
  end
catch
end

% four decimals are two more than an 8 bit channel can tell apart
str = ['[' strjoin(arrayfun(@(x) shortNum(x,4),color,'UniformOutput',false),' ') ']'];

end

% =========================================================================
function str = latticeLiteral(v)
% Lattice parameters read from an HDF5 file are float32 widened to double,
% so a is 4.0399999618530273 rather than 4.04. Write the shortest decimal
% that still reproduces the stored value to single precision.
v = double(v(:)).';
parts = cell(1,numel(v));
for k = 1:numel(v)
  d = 0;
  while d < 8 && abs(round(v(k),d) - v(k)) > eps('single')*max(1,abs(v(k)))
    d = d + 1;
  end
  parts{k} = shortNum(v(k),d);
end
str = ['[' strjoin(parts,' ') ']'];

end

% =========================================================================
function str = shortNum(x,decimals)
% x with at most that many decimals, and no trailing zeros
str = sprintf('%.*f',decimals,x);
if contains(str,'.')
  str = regexprep(str,'0+$','');
  str = regexprep(str,'\.$','');
end

end

% =========================================================================
function str = charLiteral(value)

str = ['''' strrep(char(value),'''','''''') ''''];

end

% =========================================================================
function str = vectorLiteral(v)

v = double(v(:)).';
names = {'xvector','yvector','zvector'};
for k = 1:3
  e = zeros(1,3); e(k) = 1;
  if norm(v-e) < 1e-6
    str = names{k}; return
  elseif norm(v+e) < 1e-6
    str = ['-' names{k}]; return
  end
end
str = sprintf('vector3d(%s)',mat2str(v,15));

end

% =========================================================================
function str = plottingConventionLiteral(pC)

% the script is read in the editor, not in the console, so the symbols do
% not follow the UTF8Output preference - it would make the generated text
% depend on a console font setting
[pictogram,isPictogram] = char(pC,'UTF8');
if isPictogram
  % MTEX 7.0 represents the eight axis-aligned conventions by pictograms.
  str = sprintf('plottingConvention(%s)',charLiteral(pictogram));
else
  % Keep custom, non-axis-aligned conventions reproducible as well.
  str = sprintf('plottingConvention(%s,%s)', ...
    vectorLiteral(pC.outOfScreen),vectorLiteral(pC.east));
end

end

% =========================================================================
function str = sanityPlotLiteral(ebsd,plotMask,phaseNames)

plotMask = logical(plotMask(:));
n = numel(ebsd.CSList);
if numel(plotMask) < n, plotMask(end+1:n) = false; end

counts = zeros(n,1);
for k = 1:n, counts(k) = nnz(ebsd.phaseId == k); end
counts(~plotMask(1:n)) = 0;
counts(~[ebsd.CSList.isIndexed].') = 0;

[best,phaseId] = max(counts);
if isempty(best) || best == 0
  str = '% No indexed phase selected for the sanity-check plot';
else
  mineral = charLiteral(phaseName(ebsd,phaseNames,phaseId));
  str = sprintf('plot(ebsd(%s),ebsd(%s).orientations)',mineral,mineral);
end

end
