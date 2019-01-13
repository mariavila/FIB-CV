function [ hist ] = my_imhist( I, N )
    [fmax cmax] = size(I);
    hist = zeros(N, 1);
    for f = 1:fmax
        for c = 1:cmax
            for i = 1:(N)
                if I(f,c)>= uint8((i-1)*255/N) & I(f,c)<uint8(i*255/N)
                    hist(i) = hist(i) + 1;
                end
            end
        end
    end
end

