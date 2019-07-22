function cropwindow = piGetCropWindow(img)

% piGetCropWindow - Get crop window values from a given image. 
%
% PBRT expects crop window values to be ratios of the image and relative to
% the top left corner. For example, to only render the upper left quadrant
% of an image, you would run recipe.set('cropwindow',[0 0.5 0 0.5]).
% MATLAB's getrect() function, however, returns the [x y w h] coordinates
% of a rectangle. This small function converts it to the PBRT ratios and
% then returns it to the user.
%
%    cropwindow = piGetCropWindow(img)
% 
% Required inputs
%   img - an image to display and run getrect() with
%
% Return
%   cropwindow - the cropwindow values used by PBRT 
%
%
% TL Scienstanford 2019

% Image parameters
[M,N,~] = size(img);

% Show the image
figure(); imshow(img);

% Ask user for desired crop
fprintf('Select the desired window to render. \n')
title('Select the desired window to render')
r = getrect();

% Convert to PBRT ratios
x = r(1); y = r(2); w = r(3); h = r(4);
cropwindow(1) = x/N;
cropwindow(2) = cropwindow(1) + w/N;
cropwindow(3) = y/M;
cropwindow(4) = cropwindow(3) + h/M;

end