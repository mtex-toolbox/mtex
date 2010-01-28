function c = quat2rgb(q,cs,varargin)
% converts orientations to rgb values

q0 = get_option(varargin,'q0',idquaternion);
[q omega] = getFundamentalRegion(q,q0);

if check_option(varargin,'logarithmic')
  omega = log(max(omega(:))/1000 + omega);
  omega = omega - min(omega);
end

disp(max(omega(:)));
omega = omega ./ max(omega(:));

a = reshape(double(axis(q)),[],3);

%c = 0.5 + 0.5 * reshape(a,[],3) ./ max(abs(a(:))) .* [omega omega omega];

%a = 100*reshape(a./ max(abs(a(:))),[],3);
%c = double(Lab2RGB(20+omega*80,a(:,1),a(:,2)))./255;

pos = [[1;0;0] [-1;0;0] [0;1;0] [0;-1;0] [0;0;1] [0;0;-1]];
col = [[1,0,0];[1,1,0];[0,1,0];[0,1,1];[0,0,1];[1,0,1]];
  
c = zeros(numel(q),3);

for i = 1:6
  
  c(:,1) = c(:,1) + (acos(a * pos(:,i))).^2*col(i,1);
  c(:,2) = c(:,2) + (acos(a * pos(:,i))).^2*col(i,2);
  c(:,3) = c(:,3) + (acos(a * pos(:,i))).^2*col(i,3);
end

c = c ./ repmat(max(c,[],2),1,3);
c = rgb2hsv(c);
c(:,3) = ones(size(omega));
c(:,2) = omega;
c = hsv2rgb(c);  

