function h = plot(oR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

% embedd into NaN matrix
FF = nan(length(oR.F),max(cellfun(@length,oR.F)));
for i = 1:length(oR.F)
  FF(i,1:length(oR.F{i})) = oR.F{i};
end

VR = reshape(double(oR.V.Rodrigues),[],3);
clf;
h = patch('faces',FF,'vertices',VR,'faceAlpha',0.1);
axis equal off

if nargout == 0, clear h; end