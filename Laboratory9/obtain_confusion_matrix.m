function [ confusion_matrix ] = obtain_confusion_matrix(clauSample, clauTest)
    mida = size(clauSample);
    confusion_matrix = zeros(mida);
    for lletra_sample = 1:mida
        for lletra_test = 1:mida
            if clauSample(lletra_sample) == clauTest(lletra_test)
                confusion_matrix(lletra_sample, lletra_test) = confusion_matrix(lletra_sample, lletra_test) + 1;
            end
        end
    end
end

