function sR = restrict2Lower(sR,ref)
 
if nargin==1
  ref = sR.how2plot.outOfScreen;
elseif isa(ref,'plottingConvention')
  ref = ref.outOfScreen;
end

% see restrict2Upper - a condition that is already there must not be added
% a second time, otherwise the boundary circle is drawn twice
if any(dot(sR.N(:),-ref) > 1-1e-10 & sR.alpha(:) >= 0), return; end

 % see restrict2Upper - prepending drops the frame of the region
 fr = sR.frame;
 sR.N = [-ref;sR.N(:)];
 sR.alpha = [0;sR.alpha(:)];
 sR.frame = fr;

 end
