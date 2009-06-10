function  file = generateversionnumber
%insert actual version string in xsl-style-sheet

files = dir('*.xsl');
fnames = {files.name};

for k=1:length(fnames)  
  fil = file2cell(fnames{k});
  
  %replace mtex version
  pos = find(~cellfun('isempty',strfind(fil,'<xsl:variable name="mtexversion">')));
  if ~isempty(pos)
    fil{pos} = [ '<xsl:variable name="mtexversion">' get_mtex_option('version') '</xsl:variable>'];
  end
  
  cell2file(fnames{k},fil);
end
