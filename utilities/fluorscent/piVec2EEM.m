function eem = piVec2EEM(vec)
vecData = vec(4:end);
l = numel(vecData);
s = l^0.5;

eem = reshape(vecData, [s, s])';
end