function [xnew,ynew] = addZeroPadding(x,y,nbZeros)
%ADDZEROPADDING Summary of this function goes here
% Assume x is uniformuly spaced
deltaX = diff(x(1:2));
assert(all((diff(x)-deltaX)<1e-8),'Equal spacing required for x vector') 

zeroPad=zeros(1,nbZeros);
ynew = [zeroPad y(:)' zeroPad]

xnew = [(x(1)-nbZeros*deltaX):deltaX:(x(1)-deltaX)  x(:)' (x(end)+deltaX):deltaX:(x(end)+nbZeros*deltaX)]

end

