



load('/usr/local/scratch/thomas42/psf/dgauss.22deg.3.0mm_aperture0.6-psf-depth_0.5meters.mat')

%%
maxnorm=@(x)x/max(x);

rangeRadiusPixels=200;
centersX=250
centersY=250
visPSF(oi,centersX,centersY,rangeRadiusPixels)
subplot(2,1,2)
load('psf_isetlens0.5.mat')
hold on;
plot(x_micron+1.5,maxnorm(PSF(end/2,:)))
xlim([-5 5]-0.6)
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






