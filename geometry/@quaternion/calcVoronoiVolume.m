function w = calcVoronoiVolume(rot,varargin)
% compute the the volume of the Voronoi cells which are constructed by the
% Voronoi decomposition for unit quaternions
%
% Input
%  q - @quaternion
%
% Output
%  w - Volume of the Voronoi cells
%
% See also
% quaternion\calcVoronoi voronoin vector3d/calcVoronoiArea

rot = quaternion(rot);
rot = unique(rot);

[V,C] = calcVoronoi(rot);
% [V,C,E] = calcVoronoi(quaternion(rot));

% q sind die Ecken der Tetraeder, d.h. die Zentren der Polyeder
% V sind die Zentren der Umkugel der Tetraeder, d.h. die Ecken der q umgebenden Polyeder.
% C sind die Ecken des Polyeders zu jedem q
% E sind die Kanten

% estimate volume of an Voronoi cell by the mean of the distances from 
% center to all vertices

% TODO: Do this better by calculating the volume of the cells (polyhedra on
% 3-sphere) given by the vertices (uniform quaternions).

V2 = [V;rotation.id];
len = cellfun(@length,C);
w = zeros(length(len),1);

for l = unique(len)'
  ind = len==l;
  Csub = cell2mat(C(ind));
  Wsub = angle(quaternion(rot.subSet(ind)),quaternion(V2.subSet(Csub)));
  if size(Csub,1)==1
    w(ind) = mean(Wsub);
  else
    w(ind) = mean(Wsub,2);
  end
end

w = w.^3/(sum(w.^3));

end




% The following is bad if there is one cell with 200 elements if all others
% have less than 30 elements

% Vsub = [V;rotation.id];
% maxlen = max(cellfun(@length,C));
% Csub = cell2mat(cellfun(@(x) [x zeros(1,maxlen-numel(x))],C,'uni',0));
% Csub(Csub==0) = length(Vsub);
% w = angle(quaternion(rot),quaternion(V2.subSet(Csub)));
% w(Csub==(length(Vsub))) = NaN;
% w = mean(w,2,'omitnan')
