function [ confusion_matrix, error ] = obtain_confusion_matrix(clauSample, clauTest)
    [mida, aux]= size(clauSample);
    error = 0;
    confusion_matrix = zeros(mida);
    for lletra_sample = 1:mida
        for lletra_test = 1:mida
            if clauSample(lletra_sample) == clauTest(lletra_test)
                confusion_matrix(lletra_sample, lletra_test) = confusion_matrix(lletra_sample, lletra_test) + 1;
                if lletra_sample ~= lletra_test
                    error = error + 1;
                    confon = [clauSample(lletra_sample), clauSample(lletra_test)]
                end
            end
        end
    end
    error = error/mida;
end