function plot3d(odf,varargin)
% plots odf

if odf.antipodal, ap = {'antipodal'}; else, ap = {}; end
oS = newODFSectionPlot(odf.CS,odf.SS,ap{:},'phi2',varargin{:});

S3G = oS.makeGrid('resolution',5*degree,'sections',20,varargin{:});

% bounds
[theta,rho] = polar(oS.plotGrid);
theta = repmat(theta,1,1,length(oS.phi2));
rho = repmat(rho,1,1,length(oS.phi2));
phi2 = repmat(reshape(oS.phi2,[1,1,length(oS.phi2)]),...
  [size(oS.plotGrid) 1]);
     
% get contours
contours = get_option(varargin,{'surf3','contour3'},10,'double');

contour3s(theta./degree,rho./degree,phi2./degree,odf.eval(S3G),contours,...
  'surf3',varargin{:},'xlabel','$\Phi$','ylabel','$\varphi_1$','zlabel','$\varphi2$');
 
end
