% distances(xs, ys, cx, cy)
% Pair wise distance between all (x1, y1) and all (x2, y2) points.

% 2016-11-23. Leonardo Molina.
% 2018-02-09. Last modified.
function d = distances(x1, y1, x2, y2)
    nc = numel(x2);
    np = numel(x1);
    d = NaN(np, nc);
    for c = 1:nc
        d(:, c) = (x1(:) - x2(c)) .^ 2 + (y1(:) - y2(c)) .^ 2;
    end
end