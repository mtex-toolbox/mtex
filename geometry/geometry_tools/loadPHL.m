function cs = loadPHL(fname)
% 

[pathstr, name, ext] = fileparts(char(fname));
  
if isempty(ext), ext = '.phl';end
if isempty(pathstr) && ~exist([name,ext],'file')
  pathstr = mtexCifPath;
end

% load file
if ~exist(fullfile(pathstr,[name ext]),'file')
  try
    fname = copyonline(fname);
  catch %#ok<CTCH>
    dir(fullfile(mtexCifPath,'*.phl'))
    error(['I could not find the corresponding phl file.' ...
      'Above you see the list of localy avaible phl files.'])
  end
else
  fname = fullfile(pathstr,[name ext]);
end

cs = {};
doc = xmlread(fname);
root = doc.getDocumentElement();
phaseList = root.getElementsByTagName('ClassInstance');

for i = 1:phaseList.getLength
 
  thisPhase = phaseList.item(i-1);
  if ~strcmp(thisPhase.getAttribute('Type'),'TEBSDExtPhaseEntry'), continue; end
   
  mineral = char(thisPhase.getAttribute('Name'));
  phaseEntry = thisPhase.getElementsByTagName('TEBSDPhaseEntry').item(0);
   
  %SG = phaseEntry.getElementsByTagName('SG').item(0).getFirstChild.getNodeValue;
  IT = str2num(phaseEntry.getElementsByTagName('IT').item(0).getFirstChild.getNodeValue);
  density = str2num(phaseEntry.getElementsByTagName('DENSITY').item(0).getFirstChild.getNodeValue);
  abc = str2num(phaseEntry.getElementsByTagName('Dim').item(0).getFirstChild.getNodeValue);
  angles = str2num(phaseEntry.getElementsByTagName('Angles').item(0).getFirstChild.getNodeValue);  
  
  cs{end+1} = crystalSymmetry('spaceId',IT,abc,angles,'density',density,'mineral',mineral);  
  
end

% fname = '/home/hielscher/mtex/master/data/cif/crystal.phl';
% 
