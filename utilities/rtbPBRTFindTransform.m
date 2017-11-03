function line = rtbPBRTFindTransform(fName)
% this function takes in a pbrt file and return the transform or
% concatTranform line before WorldBegin

% AJ Oct/2017
line = [];
fid = fopen(fName);
tline = fgetl(fid);

while ischar(tline)    
    if contains(tline, 'Transform') ||contains(tline, 'ConcatTransform')
        line = tline;
    end
    if contains(tline, 'WorldBegin')
        break;
    end
    tline = fgetl(fid);
end

end