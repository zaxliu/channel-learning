function mi = MI(x, y)
    codebook_x = unique(x);
    codebook_y = unique(y);
    N = length(x);
    cnt_xy = zeros(length(codebook_x), length(codebook_y));
    % count histogram
    for i = 1:length(codebook_x)
        for j = 1:length(codebook_y)
            cnt_xy(i, j) = sum((x == codebook_x(i)) & (y == codebook_y(j)));
        end
    end
    % calculate probability
    p_x = sum(cnt_xy, 2)/N;
    p_y = sum(cnt_xy, 1)/N;
    p_xy = cnt_xy/N;
    % calculate entropy
    p_xy = p_xy.*log2(p_xy);
    p_x = p_x.*log2(p_x);
    p_y = p_y.*log2(p_y);
    % entropy
%     ent_x = sum(p_y(~isnan(p_y)));
%     ent_y = sum(p_x(~isnan(p_x)));
%     ent_xy = sum(sum(p_xy(~isnan(p_xy))));
    % mi
    mi = sum(sum(p_xy(~isnan(p_xy)))) ...
        - sum(p_x(~isnan(p_x)))...
        - sum(p_y(~isnan(p_y)));
end