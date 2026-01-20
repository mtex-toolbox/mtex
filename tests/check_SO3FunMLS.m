% test funcitonalities of SO3FunMLS class for various settings, 
% as well as the interaction with other classes in all those settings

%% approximate real function, complex function, vector-valued function from
%   values on random nodes
% at the same time this tests proper handling of arrays of S2FunMLS

% symmetries
cs = crystalSymmetry('1');
ss = specimenSymmetry('1');

k = 6;

% test functions
% f(1) = SO3FunHarmonic.example; 
% cs = f(1).CS; ss = f(1).SS;
% f(2) = complex(0,1) * f(1) - f(1).^2;
% f(3) = SO3FunHarmonic(2 * rand(64, 1, 1) - 1, cs, ss);
f(1:k) = SO3FunHarmonic(2 * rand(32, 1, k) - 1, cs, ss, 'antipodal');
f = reshape(f, 3, 1, 2);
for i = 1 : numel(f)
  f(i) = SO3FunHarmonic(@(ori)(real(f(i).eval(ori))));
end
figure(1); plot(f); colorbar;

% grid for the test function, values on the grid
N = 1e4;
ori = orientation.rand(1, N, 2);
f_values = f.eval(ori);

% test nodes
ori2 = orientation.rand(1e4);


%% test with standard parameters only
sF = SO3FunMLS(ori, f_values, cs, ss, 'antipodal');
% sF.detectOutliers = true;
% sF.outlierDetectionRange = 5;

% for i = 1 : numel(f)
%   figure(1); plot(f(i)); colorbar;
%   figure(2); plot(sF(i)); colorbar; 
%   figure(3); plot(sF(i) - f(i)); colorbar;
%   waitforbuttonpress();
% end

figure(1); plot(f(2,1)); colorbar;

f = squeeze(f);

diff = sF - f;
disp(max(abs(diff.eval(ori2))));
figure(2); plot(sF(2,1)); colorbar;

%% same test, but with range search instead of knn search
sF.nn = 0;
sF.delta = sF.compute_delta();
figure(1); plot(f); colorbar;
figure(2); plot(sF); colorbar;
diff = sF - f;
disp(max(abs(diff.eval(ori))));

%% test various parameter settings for the same test function
ori2 = orientation.rand(1e3);
% f = SO3FunHarmonic(2 * rand(64, 1) - 1);
f = @(ori)(sin(ori.a.^2) .* cos(ori.b) - exp(ori.c.^2) .* ori.d.^2);
f = SO3FunHarmonic.quadrature(f);
f = @(ori)(real(f.eval(ori)));
f = SO3FunHarmonic(f);
f_values = f.eval(ori);

flags = {'centered', 'subsample', 'tangent'};
marker = logical(dec2bin((0:7)') - '0');

mls_values = zeros(numel(ori2), 8);

clear sF;
for i = 1 : 8
  % 'bla' avoids empty applied_flags for i = 1
  applied_flags = ['bla', flags(marker(i,:))];
  numflags = sum(marker(i,:));
  sF{i} = SO3FunMLS(ori, f_values, applied_flags{:});
  % sF{i}.degree = 2;
  % sF{i}.nn = 0;
  % sF{i}.delta = sF{i}.compute_delta() * 3;
  mls_values(:,i) = sF{i}.eval(ori2);
end
% NOTE: we expect only 2 different results, since outlierDetection should have
%       no influence at all (for nice f with clean data), and if tangent is
%       true, then centered should also be set to true in the constructor 

% TODO: for rangesearch we observe: 
%       centered = true, subsample = true, tangent = false gives bigger error
%       for some reason
%       it gets better with larger delta and smaller degree though

errors = abs(mls_values - f.eval(ori2));
disp(max(errors, [], 1));

%% test outlier detection 
num_outliers = round(numel(ori) * .01);
I = randperm(numel(ori), num_outliers);
noisy_values = f_values;
noisy_values(I) = 100 * mean(abs(f_values)) * (2 * rand(num_outliers, 1) - 1);

% MLS without outlier detection
sF = SO3FunMLS(ori, noisy_values);
figure(1); plot(f); colorbar;
figure(2); plot(sF); colorbar;

% MLS with outlier detection
sF2 = SO3FunMLS(ori, noisy_values);
sF2.detectOutliers = true;
sF2.outlierDetectionRange = 25;
figure(3); plot(sF2); colorbar;

%% test outlier detection with range search

% MLS without outlier detection
sF = SO3FunMLS(ori, noisy_values);
sF.nn = 0;
sF.delta = sF.compute_delta();

figure(1); plot(f); colorbar;
figure(2); plot(sF); colorbar;

% MLS with outlier detection
sF2 = SO3FunMLS(ori, noisy_values);
sF2.detectOutliers = true;
sF2.outlierDetectionRange = round(sF2.dim * .7);
sF.nn = 0;
sF.delta = sF.compute_delta() * 2;

figure(3); plot(sF2); colorbar;