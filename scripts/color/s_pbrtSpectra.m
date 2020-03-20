%% s_pbrtSpectralFunctions
%
% Analyze the relationship between RGB and spectra in PBRT
%
% See also
%

%% Make a wide range of RGB values

s = 0:0.2:1;
[R,G,B] = meshgrid(s,s,s);
RGB = [R(:),G(:),B(:)];

%% Calculate the PBRT reflectance spectra

wave = 400:10:700;
reflectance = zeros(numel(wave),size(RGB,1));
for ii=1:size(RGB,1)
    reflectance(:,ii) = pbrtRGB2Reflectance(RGB(ii,:),'wave',wave);
end

%%  These are the spectra as we cycle through RGB

ieNewGraphWin;
mesh(1:216,wave,reflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet)

%%  What are the basis functions?

% Here are the basis functions
[U,S,V] = svd(reflectance);
plot(wave,U(:,1:3));
% R = U*S*V';
% mesh(1:216,wave,R);

%% The 3D approximation to their curves
T = S;
for ii=4:31
    T(ii,ii) = 0;
end
eReflectance = U*T*V';

ieNewGraphWin;
mesh(1:216,wave,eReflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet)

% Here are the equivalent RGB weights for these basis functions
wgts = T*V';
wgts = wgts(1:3,:);

eReflectance = U(:,1:3)*wgts;
ieNewGraphWin;
mesh(1:216,wave,eReflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet)

%% What is the relationship between the wgts and RGB?
%  wgts = L*RGB'
L = wgts*pinv(RGB'); 
eWgts = L*RGB';

plot(eWgts(:),wgts(:),'.')

%%
eReflectance = U(:,1:3)*eWgts;
ieNewGraphWin;
mesh(1:216,wave,eReflectance);
xlabel('RGB'); ylabel('wave')
colormap(jet)

%% END
    