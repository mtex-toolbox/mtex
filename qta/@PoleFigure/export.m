function export(pf,filename,varargin)
% export pole figure in an ASCII file
%
% the pole figure data for each crystal direction are stored in a seperate 
% ASCII file. The ASCII file contains three columns - |theta| - |rho| -
% |intensity|, where (|theta|, |rho|) are the polar coordinates of the specimen
% directions and |intensity| is the diffraction intensity
%
% Input
%  pf       - @PoleFigure
%  filename - string
%
% Options
%  DEGREE - theta / rho output in degree instead of radians
%
% See also
% loadPoleFigure_generic

for i = 1:pf.numPF
  dname = [filename,'_',char(pf.allH{i}),'.txt'];

  [theta,rho] = polar(pf.allR{i});
	if check_option(varargin,'degree')
		theta = theta * 180'/pi;		
		rho = rho * 180'/pi;
	end
	d = [theta(:),rho(:),pf.allI{i}(:)]; %#ok<NASGU>
  save(dname,'d','-ASCII');
    
end
