function [odf,options] = loadODF_VPSC(fname,varargin)

options = delete_option(varargin,'check');

% read file header
hl = file2cell(fname,4);

% check that this is a vpsc text file
assert(~isempty(strmatch('TEXTURE AT STRAIN',hl{1})),...
  'Interface VPSC does not fit file format!');
  
if check_option(varargin,'check')
  odf = ODF;
  options = delete_option(varargin,'check');
  return; 
end

% detect number of strain steps
nOri = sscanf(hl{4},'B %d');

% read file
d = txt2mat(fname,'NumHeaderLines',0,'InfoLevel',0,'ReplaceExpr',{{'TEXTURE AT STRAIN = ',''}});

cs = getClass(varargin,'crystalSymmetry',crystalSymmetry('432'));

numStrain = round(size(d,1) / (nOri+4));


for k = 1:numStrain
  range = 4+(1+(nOri+4)*(k-1):(nOri+4)*(k-1)+nOri);
  ori = orientation.byEuler(d(range,1:3) * degree,cs);
  weights = d(range,4);
  
  odf{k} = calcDensity(ori,'weights',weights,varargin{:}); %#ok<AGROW>
  odf{k}.opt.strain = d(1+(nOri+4)*(k-1),1); %#ok<AGROW>
  odf{k}.opt.strainEllipsoid = d(2+(nOri+4)*(k-1),1:3); %#ok<AGROW>
  odf{k}.opt.strainEllipsoidAngles = d(3+(nOri+4)*(k-1),1:3); %#ok<AGROW>

  % also store data (individual orientations, ellipsoids, Taylor factors)
  odf{k}.opt.orientations = ori;
  odf{k}.opt.data = d(range,5:size(d,2));
  
end

if numStrain == 1, odf = odf{1}; end

end
