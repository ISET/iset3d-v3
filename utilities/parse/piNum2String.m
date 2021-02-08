function string = piNum2String(num)
string='';

for ii = 1:numel(num)
    if isinteger(num)
        string = [string, ' ' ,num2str(num(ii))];
    else
        formatSpec = '%.5f';
        string = [string, ' ' ,num2str(num(ii), formatSpec)];
    end
end
end