function [ clauTest ] = nearest_neighbour_of_text( clauSample, caracteristiquesSample, caracteristiquesTest )   
    [f, c] = size(caracteristiquesSample);
    [fs, cs] = size(clauSample);
    clauTest = zeros(fs, cs);
    for lletra_test = 1:f
       nearest_neighbour = 0;
       min_dist = Inf;
       for lletra_sample = 1:f
           euclidean_distance = 0;
           for caracteristica = 1:c
               euclidean_distance = euclidean_distance + (caracteristiquesTest(lletra_test, caracteristica) - caracteristiquesSample(lletra_sample, caracteristica))^2;
           end
           if euclidean_distance < min_dist
               min_dist = euclidean_distance;
               nearest_neighbour = lletra_sample;
           end
       end
       clauTest(lletra_test) = clauSample(nearest_neighbour);
    end
end