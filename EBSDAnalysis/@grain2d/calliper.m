function [cd, pcd, omega] = calliper(grains,varargin)
% Calliper (Feret diameter) of a grain in measurement units, the projection
% length normal to it and its direction/trend.
%
% Input:
%  grains   - @grain2d
%
% Output:
%  cd       - calliper (default = maximum calliper = grain2d/diameter)
%  pcd      - projection length length normal to cd
%  omega    - angle giving direction/trend of cd
%
% Options:
%  shortest  - instead of maximum calliper, derive minimum (cd),
%             length normal to minimum  (pcd) and trend of minimum calliper
%             (omega)
%              

% (reusing code from grain2d/diameter)

V = grains.V;
poly = grains.poly;
cd = zeros(size(grains)); pcd=cd; omega=cd;


for ig = 1:length(grains)
  Vg = V(poly{ig},:);
  % reduce to convex hull
  Vg = Vg(convhulln(Vg),:);
  
  if ~check_option(varargin,'shortest') || isempty(varargin) % find longest projection
    
    diffVg = bsxfun(@minus,reshape(Vg,[],1,2),reshape(Vg,1,[],2));
    diffVg = sum(diffVg.^2,3);
    [md, id ]=max(diffVg(:));
    % find corresponding vertices
    [I,J] = ind2sub(size(diffVg),id);
    % first point  Vg(I,1),Vg(I,2)
    % second point  Vg(J,1),Vg(J,2)
    % but apparently not always (?)
    % get the angle with x-axis
    omega(ig)=atan2(Vg(I,2) - Vg(J,2),Vg(I,1) - Vg(J,1));
    % get the length
    cd(ig) = sqrt(md);
    % get the particle length (projection length perpendicular to cd)
    pcd(ig) = projectionLength(Vg,omega(ig)+pi/2);
    % in case we want to get the coordiantes related to cd.
    % v{ig}=[Vg(I,:) Vg(J,:)];
    
  else % find the shortest projection length (brute force approach)
    % TODO: use something nicer similar to http://gg.gg/aomlt while
    % projetion length seems faster instead of computing all anitpodal
    % lines for grains with many vertices.
    omegaP=[0:1:179]*degree;
    pl = projectionLength(Vg);
    [cd(ig),idmin]=min(pl); % shortest projection length
    omega(ig) =  omegaP(idmin);
    pcd(ig) = pl(mod(idmin+90,180));
  end
  
  % keep omega in range
  omega(omega<0)=omega(omega<0)+pi;
  
end


  function pl = projectionLength(Vg,varargin)
    % return the projection length of group of vertices as a function
    % of angle omega. For omega=0, it should be the projection
    % length against the x= axis
    %
    % Input:
    %  Vg     - list of vertices for a sngle grain
    %  omegaP - list of angles (default 0:pi in 1 degree steps)
    %
    % Output:
    %  pl     - list of projection lengths as a function of omegaP
    %
    
    if nargin>1 && isnumeric(varargin{1})
      omegaP=varargin{1};
    else
      omegaP=[0:1:179]*degree;
    end
    pl = zeros(length(omegaP),1);
    % rotate everything
    % TODO: maybe omit this loop
    for j=1:length(omegaP)
      VgR = [cos(omegaP(j)) sin(omegaP(j)); -sin(omegaP(j)) cos(omegaP(j))]*Vg';
      pl(j)=max(VgR(1,:))-min(VgR(1,:)); % projection length
    end
  end

end

