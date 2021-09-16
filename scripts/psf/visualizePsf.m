




%% Select PSF centers
data=oi{1}.data.photons(:,:,1);
figure;
imagesc(data)   

[centersX,centersY] = getpts


%% Depth = 1 m
 load('/home/thomas42/Documents/MATLAB/libs/iset3d/local/psf-depth_1meters.mat')
centersX = [ 501   500   501   501   501   501   500   501   500   500   501];
centersY = [ 501   543   587   630   671   717   757   799   840   881   921];
rangeRadius=10





%% Depth = 0.5 m
 load('/home/thomas42/Documents/MATLAB/libs/iset3d/local/psf-depth_0.5meters.mat')
 centersX=[500   500   501   500   500   500];
 centersY=[500   587   673   759   841   922];
radiusRadius=10;

%% Visualize
visPSF(oi,centersX,centersY,rangeRadius)







