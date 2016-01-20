function entropy = ent(x)
    codebook_x = unique(x);
    N = length(x);
    cnt_x = zeros(length(codebook_x), 1);
    for i = 1:length(codebook_x)
            cnt_x(i) = sum((x == codebook_x(i)));
    end
    p_x = cnt_x/N;
    p_x = p_x.*log2(p_x);
    entropy = -1*sum(p_x(~isnan(p_x)));
end