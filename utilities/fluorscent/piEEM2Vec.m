function vec = piEEM2Vec(wave, eem)
% The data are converted to a vector like this
flatEEM = eem';
vec = [wave(1) wave(2)-wave(1) wave(end) flatEEM(:)'];
end