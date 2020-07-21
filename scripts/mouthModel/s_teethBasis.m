% s_teethBasis

%% init
ieInit;

%% Read 
wave = 400:10:600;
extrapVal = 0;
teethBasis  = ieReadSpectra('Teeth_3BasisFunctions', wave, extrapVal);
%{
ieNewGraphWin;
plot(wave, teethBasis);
ylim([-0.8 0.6])
%}
%% Load teeth reflectances
teethRefl = ieReadSpectra('TeethReflectanceMeasurements_8subjects',...
                wave, extrapVal);



%% Calculate weights
% The first 8 samples are meaningful
wgtsPred = zeros(size(teethRefl, 2)/2, 3);

for ii=1:size(teethRefl, 2)/2
    wgtsPred(ii,:) = teethRefl(:,ii) \ teethBasis;
end

%% Evaluate the reconstruction

teethReflPred = teethBasis * wgtsPred';

%% Compare

% 8 samples, we do 2x4
ieNewGraphWin;
rows = 2; cols = 4;
for ii =1:size(teethRefl, 2)/2
    subplot(rows, cols, ii);
    plot(wave, teethRefl(:,ii), 'r', wave, teethReflPred(:,ii), 'b');
    legend('Measured reflectance', 'Estimated reflectance')
    ylim([0 1])
end


%% Load teeth reflectances
teethRefl = ieReadSpectra('TeethReflectanceMeasurements_8subjects',...
                wave, extrapVal);
%% basis analysis on other measurements
wave = 365:5:705;
[tBasis, wgts] = basisAnalysis(teethRefl, wave, 'vis', true);

recRefl = tBasis * wgts;

%%
ieNewGraphWin;
rows = 2; cols = 4;
for ii =1:size(recRefl, 2)/2
    subplot(rows, cols, ii);
    plot(wave, recRefl(:,ii), 'r', wave, teethRefl(:,ii), 'b');
    legend('Measured reflectance', 'Estimated reflectance')
    ylim([0 1])
end