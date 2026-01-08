% test funcitonalities of S2FunMLS class for various settings, 
% as well as the interaction with other classes in all those settings

%% approximate real function, complex function, vector-valued function from
%   values on random nodes
% at the same time this tests proper handling of arrays of S2FunMLS

cs = crystalSymmetry('222');

% test functions
f(1) = S2Fun.smiley; 
f(2) = complex(0,1) * f(1) - f(1).^2;
f(3) = S2FunHarmonic(2 * rand(64, 1, 1) - 1);
f(4:6) = S2FunHarmonic(2 * rand(32, 1, 3) - 1);
f = reshape(f, 3, 2);
f = S2FunHarmonicSym.quadrature(f, cs);
figure(1); plot(f); colorbar;

% grid for the test function, values on the grid
N = 1e4;
v = vector3d.rand(N);
f_values = f.eval(v);

% test nodes
w = vector3d.rand(1e4);


%% test with standard parameters only
sF = S2FunMLS(v, f_values);
sF.detectOutliers = true;
sF.outlierDetectionRange = 3;
figure(2); plot(sF); colorbar;
diff = sF - f;
disp(max(abs(diff.eval(w))));

%% same test, but with range search instead of knn search
sF.nn = 0;
sF.delta = sF.compute_delta() * 2;
figure(2); plot(sF); colorbar;
diff = sF - f;
disp(max(abs(diff.eval(w))));


%% test with antipodal option 
f = @(v)(sin(v.x).^2 .* cos(v.y) + tan(v.z.^2));
f = S2FunHarmonic(f);
figure(1); plot(f, '3d'); colorbar;

f_values = f.eval(v);
sF = S2FunMLS(v, f_values);
sF.antipodal = f.antipodal;
figure(2); plot(sF, '3d'); colorbar;
diff = sF - f;
disp(max(abs(diff.eval(w))));

%% test antipodal option with range search 
sF.nn = 0;
sF.degree = 3;
sF.delta = sF.compute_delta * 1;
figure(2); plot(sF, '3d'); colorbar;
diff = sF - f;
disp(max(abs(diff.eval(w))));

%% test various parameter settings for the same test function
w2 = vector3d.rand(1e3);
f = S2FunHarmonic(2 * rand(40,1) - 1);
f = @(v)(real(f.eval(v)));
f = S2FunHarmonic(f);
f_values = f.eval(v);

flags = {'centered', 'monomials', 'subsample', 'tangent'};
marker = logical(dec2bin((0:15)') - '0');

mls_values = zeros(numel(w2), 16);

clear sF;
for i = 1 : 16
  % tangent need monomials
  if (mod(i+2,4) == 0)
    continue;
  end

  % 'bla' avoids empty applied_flags for i = 1
  applied_flags = ['bla', flags(marker(i,:))];
  numflags = sum(marker(i,:));
  sF{i} = S2FunMLS(v, f_values, applied_flags{:});
  sF{i}.nn = 0;
  sF{i}.delta = sF{i}.compute_delta() * 2;
  mls_values(:,i) = sF{i}.eval(w2);
end

errors = abs(mls_values - f.eval(w2));
errors(:, [2, 6, 10, 14]) = 0;
disp(max(errors, [], 1));

%% test annoying data - standard
try 
  pf = pf{1};
catch 
  mtexdata dubna; 
  pf = pf{1};
end
v = pf.r(:);
f_values = pf.intensities(:);
v2 = [-v; v];
figure(1); scatter(v, f_values); colorbar;

sF = S2FunMLS(v, f_values);
sF.antipodal = true;
figure(2); plot(sF); colorbar;

%% test annoying data - identify and remove outliers 
%   (technically they do not get removed, but their weight gets reduced to
%    almost zero)
sF.detectOutliers = true;
sF.outlierDetectionRange = 7;
figure(2); plot(sF); colorbar;

%% same as before, but with range search instead
sF.nn = 0;
sF.delta = sF.compute_delta();
figure(2); plot(sF); colorbar;
% diff = f_values - sF.eval(v);
% disp(max(abs(diff)));

%% check if the previous 2 test get better if we have outliers on a regular grid
% create test function
v = fibonacciS2Grid(N);
f = S2FunHarmonic(2 * rand(40, 1) - 1);
figure(1); plot(f); colorbar;

% make 1% of the data noisy
f_values = f.eval(v);
num_outliers = round(numel(v) * .01);
I = randperm(numel(v), num_outliers);
noisy_values = f_values;
noisy_values(I) = 100 * mean(abs(f_values)) * (2 * rand(num_outliers, 1) - 1);

% MLS without outlier detection
sF = S2FunMLS(v, noisy_values);
figure(2); plot(sF); colorbar;

% MLS with outlier detection
sF2 = S2FunMLS(v, noisy_values);
sF2.detectOutliers = true;
sF2.outlierDetectionRange = 7;
figure(3); plot(sF2); colorbar;

%% same as before, but now with range search on the regular grid

% MLS without outlier detection
sF.nn = 0;
sF.delta = sF.compute_delta();
figure(2); plot(sF); colorbar;

% MLS with outlier detection
sF2.nn = 0;
sF2.delta = sF2.compute_delta();
figure(3); plot(sF2); colorbar;

