function demosiacImage = demosaicRCCC(mosaicImage)
% RCCC images are converted into monochrome images
%
% Zhenyi Liu
% ref: https://www.analog.com/media/en/technical-documentation/application-notes/EE358.pdf
%%
kernel = [0  0 -1  0  0;
          0  0  2  0  0;
          -1 2  4  2 -1;
          0  0  2  0  0;
          0  0 -1  0  0]/8;
%%
c = mosaicImage(:,:,2);
[V,H,~] = size(mosaicImage);
mosaicImage_ex = [mosaicImage(:,2,:) mosaicImage mosaicImage(:,(H-1),:)];
mosaicImage_ex = [mosaicImage_ex(2,:,:);mosaicImage_ex;mosaicImage_ex((V-1),:,:)];
r_ex = mosaicImage_ex(:,:,1);
r_mask = r_ex; r_mask(r_mask~=0)=1;
c_ex = mosaicImage_ex(:,:,2);
imageMix = r_ex+c_ex;
imageMix_conv = conv2(imageMix,kernel,'same');
r_conv = imageMix_conv.*r_mask;

r_conv(1,:,:)  = [];
r_conv(:,1,:)  = [];
r_conv(end,:,:)= [];
r_conv(:,end,:)= [];
demosiacImage = c + r_conv;
end