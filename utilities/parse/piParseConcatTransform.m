function [rotation, translation, tform] = piParseConcatTransform(txt)
% Given a string 'txt' extract the information about transform.

posA = strfind(txt,'[');
posB = strfind(txt,']');

tmp  = sscanf(txt(posA(1):posB(1)), '[%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f]');
tform = reshape(tmp,[4,4]);
dcm = [tform(1:3); tform(5:7); tform(9:11)];

[rotz,roty,rotx]= piDCM2angle(dcm);
inv_dcm = piAngle2dcm(rotz, roty, rotx);

% if ~isreal(rotz) || ~isreal(roty) || ~isreal(rotx)
%     warning('piDCM2angle returned complex angles.  JSONWRITE will fail.');
%     % dcm
%     % txt(posA(1):posB(1))
% end

%{
% Forcing to real is not a good idea.  
rotx = real(rotx*180/pi);
roty = real(roty*180/pi);
rotz = real(rotz*180/pi);
%}
% {                   
rotx = rotx*180/pi;
roty = roty*180/pi;
rotz = rotz*180/pi;
%}

% Comment needed
rotation = [rotz, roty, rotx;
                fliplr(eye(3))];

translation = reshape(tform(13:15),[3,1]);
diff = inv_dcm(:) - dcm(:);
if numel(find(diff>0.1))>1 || ~isreal(rotz) || ~isreal(roty) || ~isreal(rotx)
    warning('Unkown rotation, using transform');
    rotation = [];
end