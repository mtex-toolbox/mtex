function sR = restrict2Upper(sR,ref)
 
if nargin==1
  ref = sR.how2plot.outOfScreen;
elseif isa(ref,'plottingConvention')
  ref = ref.outOfScreen;
end

% do not add the condition twice, the boundary is drawn once per condition
if any(dot(sR.N(:),ref) > 1-1e-10 & sR.alpha(:) >= 0), return; end

% vector3d/cat takes its properties from the first argument, so restore the frame
fr = sR.frame;
sR.N = [ref;sR.N(:)];
sR.alpha = [0;sR.alpha(:)];
sR.frame = fr;

end
