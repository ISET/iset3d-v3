load('oiComparisonDgauss5000.mat')




%% Select PSF centers
 %data=oi{i}.data.photons(:,:,1);
 %figure;
 %imagesc(data)   

%[centersX,centersY] = getpts

centersX = [round(1.0e+03 *[      1.9244    2.3076    2.6876    3.0692    3.4397]) [1924        2308        2688        3069        3440]]
centersY = [round(1.0e+03 *[      2.3071    2.3063    2.3064    2.3073    2.3092])  [ 2307        2306        2306        2307        2309]]



range = @(x) [(x-30):(x+30)];
%%
rangeRadius=30
visPqqSF(oi,centersX,centersY,rangeRadius)


%% Indpeendent verification of PSF
lensfile  = 'dgauss.22deg.3.0mm.json';
lens = lensC('file',lensfile)
otf2psf(oi{1}.optics.OTF.OTF)



