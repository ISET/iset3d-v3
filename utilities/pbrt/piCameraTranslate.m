function thisR = piCameraTranslate(thisR,translate)
% translate the current position of the camera
% See also, piCameraRotate;
% Zhenyi, 2019
thislookAt = thisR.lookAt;
newlookAt = thislookAt;
newlookAt.from = thislookAt.from + translate;
newlookAt.to = thislookAt.to + translate;
thisR.lookAt = newlookAt;
end