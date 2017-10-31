function matrix = lookat2transform(from, to, up)
matrix = zeros(4,4);
matrix(1:3, 4) = from;
dir = (to - from)/norm(to - from);
norm_up = up/norm(up);
left = cross(norm_up, dir);
left = left/norm(left);
new_up = cross(dir, left);
matrix(1:3, 1) = left;
matrix(1:3, 2) = new_up;
matrix(1:3, 3) = dir;
matrix(4,4) = 1;
matrix = inv(matrix);
end