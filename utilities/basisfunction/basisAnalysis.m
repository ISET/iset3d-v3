function [rBasis, wgts] = basisAnalysis(reflectance, wave,varargin)

%% parse input
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('reflectance', @isnumeric)
p.addRequired('wave', @isvector)
p.addParameter('nbasis', 3, @isnumeric)
p.addParameter('vis', false, @islogical)
p.parse(reflectance, wave, varargin{:})

reflectance = p.Results.reflectance;
wave        = p.Results.wave;
nBasis      = p.Results.nbasis;
vis         = p.Results.vis;

%% How many samples
nSamples = size(reflectance, 2);
%%  What are the basis functions?
% Here are the basis functions
[Basis,S,V] = svd(reflectance);

% plot(wave,Basis(:,1:nBasis)); xaxisLine;
% R = Basis*S*V';
% mesh(1:nSamples,wave,R);

%% The 3D approximation to their curves
T = S;

for ii=nBasis+1:nSamples
    T(ii,ii) = 0;
end

%{
ieNewGraphWin;
mesh(1:nSamples,wave,reflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet); title('Original')
%}

% Here are the equivalent RGB weights for these basis functions
wgts = T*V';
wgts = wgts(1:nBasis,:);

rBasis = Basis(:,1:nBasis);
eReflectance = rBasis*wgts;
%{
ieNewGraphWin;
mesh(1:nSamples,wave,eReflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet); title('Approximation')
%}

%%  Compare data points of estimated reflectances and true reflectances

if vis
ieNewGraphWin;
plot(eReflectance(:), reflectance(:),'.')
identityLine; grid on
xlabel(sprintf('estimated reflectance using %d basis functions', nBasis))
ylabel('True reflectances')
end

%% Check each of measured data reflectances
%{
% 12 samples, we do 3x4
ieNewGraphWin;
rows = 3; cols = 4;
for ii =1:nSamples
    subplot(rows, cols, ii);
    plot(wave, reflectance(:,ii), 'r', wave, eReflectance(:,ii), 'b');
    legend('Measured reflectance', 'Estimated reflectance')
end
%}
end