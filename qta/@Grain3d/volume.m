function vol = volume( grains )
% calculates the volume of a polyeder
%
%% Input
%  p - @Grain3d
%
%% Output
%  V  - volume of polyeder, working right only if all triangles/quadrilateral have same orientation!
%

n = cell(size(grains,1),1);

F = get(grains,'F');
V = get(grains,'V');

I_FD = get(grains, 'I_FDext') + get(grains, 'I_FDsub');
I_FG = I_FD * get(grains,'I_DG');
[f,g,orientation] = find(I_FG);

F = F(f,:);

b = faceBaryCenter(V,F,sum(I_FG~=0,1));
n = normal(grains);

c = cellfun(@times,b,n,'UniformOutput',false);
c = cellfun(@(x) sum(x(:)),c,'UniformOutput',false);
vol = sum(cell2mat(c),2)./2;


function b = faceBaryCenter(v,f,d)

b = mat2cell(mean(reshape(v(f(:,1:3),:),[],3,3),3),d,3);
if size(f,2)>3
  b(:,2) = mat2cell(mean(reshape(v(f(:,[3 4 1]),:),[],3,3),3),d,3);
end

b(any(cellfun('isempty',b),2),:) = [];
