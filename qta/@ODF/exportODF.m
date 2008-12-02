function exportODF(odf,filename,varargin)
% save ODF values to file
%
%% Input
%  odf      - ODF to be exported
%  filename - name of the ascii file


%% define the orientations where the ODF should be evaluated
% this is a little bit complicated. I proberbly will shift it to SO3Grid in
% the future.

% resolution
res = 5*degree;

% symmetries
[CS,SS] = getSym(odf);

% phi1
if rotangle_max_y(CS) == pi && rotangle_max_y(SS) == pi
  phi1_max = pi/2;
else
  phi1_max = rotangle_max_z(odf(1).SS);
end
phi1 = 0:res:phi1_max;
  
% Phi
Phi_max = min(rotangle_max_y(CS),rotangle_max_y(SS))/2;
Phi = 0:res:Phi_max;
 
% phi2
phi2_max = rotangle_max_z(CS);
phi2 = 0:res:phi2_max;

% build up a uge phi1 x Phi x phi2 matrix
[Phi phi2] = meshgrid(Phi,phi2);
phi1 = repmat(reshape(phi1,[1,1,numel(phi1)]),[size(Phi),1]);
Phi  = repmat(Phi,[1,1,size(phi1,3)]);
phi2 = repmat(phi2,[1,1,size(phi1,3)]);
  
% convert to rotations
rot = euler2quat(phi1(:),Phi(:),phi2(:),'Bunge');

%% evaluate ODF
v = eval(odf,rot);

%% build up matrix to be exported
d = [phi1(:)/degree,Phi(:)/degree,phi2(:)/degree,v(:)]; %#ok<NASGU>

%% save matrix
save(filename,'d','-ascii');

