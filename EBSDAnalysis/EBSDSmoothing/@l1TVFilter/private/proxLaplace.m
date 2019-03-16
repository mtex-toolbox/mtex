function ori = proxLaplace(ori,lambda,varargin)

% compute a mean map

d_ori = zeros([size(ori)+2,4]);
d_ori(2:end-1,2:end-1,:) = double(ori);

mean_ori = zeros([size(ori) 4]);

count = zeros(size(mean_ori));

% compute sliding mean
for i = -1:1
  for j = -1:1
    [mean_ori,count] = nanplus(mean_ori,...
      d_ori((1:end-2)+1+i,(1:end-2)+1+j,:),count);
  end
end

mean_ori = mean_ori ./ count;

% compute variance to mean
var2mean = zeros(size(ori));
for i = -1:1
  for j = -1:1
  
    var2mean = nanplus(var2mean,...
      sum((mean_ori - d_ori((1:end-2)+1+i,(1:end-2)+1+j,:)).^2,3));
  
  end
end
std = sqrt(var2mean./count(:,:,1));

% robust mean - take only 
mean_ori2 = zeros([size(ori) 4]);

% compute sliding mean
for i = -1:1
  for j = -1:1
    
    dist = sqrt(sum((d_ori((1:end-2)+1+i,(1:end-2)+1+j,:) - mean_ori).^2,3));
    ind =  dist < 1.1*std;
    %weight = (dist < 1.1*std) ./ (dist.^2+0.0001);
    weight = 1 ./ (dist.^2+0.0001);
    
    mean_ori2 = mean_ori2 + d_ori((1:end-2)+1+i,(1:end-2)+1+j,:) .* weight;
  end
end

ori2 = normalize(quaternion(mean_ori2(:,:,1),mean_ori2(:,:,2),mean_ori2(:,:,3),mean_ori2(:,:,4)));

% compute geodetic distance
t = min((2*lambda) ./ angle(ori,ori2),1);

ori = normalize((1-t).*ori + t.*ori2);
  
