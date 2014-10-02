function [axes,angle] = getMinAxes(rot)


axes = rot.axis;
angle = rot.angle;
angle = min(angle,2*pi-angle);

ind = isnull(angle);
axes(ind) = [];
angle(ind) = [];
  
[axes,~,pos] = unique(axes(:),'antipodal');
angle = arrayfun(@(i) min(angle(pos==i)) ,1:length(axes));

% sort axes
[angle,idx] = sort(angle,2,'descend');
axes = axes(idx);

end
