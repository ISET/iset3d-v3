




load('/usr/local/scratch/thomas42/psf/dgauss.22deg.50.0mm_aperture6.0-psf-depth_0.34644meters.mat')

%%
maxnorm=@(x)x/max(x);
load('psf_isetlens3000m.mat')
figure(1);clf
plot(x_micron,maxnorm(PSF(end/2,:)))
hold on ; plot(Y(:,1),maxnorm(Y(:,2)))
xlim([-15 15])
%%

close all
rangeRadiusPixels=149;
centersX=300
centersY=300
visPSF(oi,centersX,centersY,rangeRadiusPixels)
subplot(2,1,2)

hold on;
plot(1.5*x_micron,maxnorm(PSF(end/2,:)))

legend('PBRT','iset lens')
%% Select PSF centers
data=oi{1}.data.photons(:,:,1);
figure;

imagesc(data)   


%%

[centersX,centersY] = getpts;
centersX=round(centersX')
centersY=round(centersY')



%% Visualize

rangeRadiusPixels=20;
visPSF(oi,centersX,centersY,rangeRadiusPixels)



%% Lens focal point






