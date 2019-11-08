function spectra = loadallspectra(file)
% load all spectra files of a Dubna meassurement cycle
%
% Input
%  filename - 
%
% Output
%  spectra - []
%

dir = file(1:max(strfind(file,'/')));
maxrot = findmax(dir);
fprintf('load detector: ');

for det=1:19
	fprintf([char(96+det),', ']);
	
	for rot=0:maxrot
		
		s = int2str(rot);
		if rot<10, s = ['0',s];end %#ok<AGROW>

		spec = loadspectra([file,'.',char(96+det),s]);
		if ~isempty(spec),  spectra(:,rot+1,det)=spec;end %#ok<AGROW>
	end
end
disp('.');

function m = findmax(directory)

l = dir(directory);
if isempty(l), error('directory not found or empty');end
for i=3:length(l), m(i-2) = max([0,str2num(l(i).name(end-1:end))]);end %#ok<ST2NM,AGROW>
m = max(m);
