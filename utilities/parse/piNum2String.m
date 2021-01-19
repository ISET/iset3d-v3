function string = piNum2String(num)
string='';
for ii = 1:numel(num)
    string = [string, ' ' ,num2str(num(ii))];
end
end