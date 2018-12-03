function [ caracteristiques ] = obtain_text_characteristics( I )
    % Binaritzem imatge
    I = I<180;
    % Cridem a region props per obtenir les imatges de les lletres
    LlistaLletres = regionprops(I, 'BoundingBox');
    % Caracteristiques es una matriu 
    caracteristiques = [];
    for i = 1:30 % per cada lletra fem:
        %obtenim la BB de la lletra
        BoundingBoxLletra = LlistaLletres(i).BoundingBox;  
        %augmentem els marcs
        BoundingBoxLletra = BoundingBoxLletra + [-1 -1 1 1];
        %obtenim la imatge de la lletra
        Illetra = imcrop(I, BoundingBoxLletra);
        %calculem les caracteristiques d'aquesta
        carac = obtaincharacteristics(Illetra);
        %afegim el valor a la variable de retorn
        caracteristiques = [caracteristiques; carac];
    end
    %Normalitzem les caracteristiques perque totes tinguin un rang similar (entre 0 i 1)
    [f, c] = size(caracteristiques);
    for i =  1:c
        carac = caracteristiques(:, i);
        maxim = max(carac);
        minim = min(carac);
        for j = 1:f
            caracteristiques(j, i) = (maxim - caracteristiques(j, i)) / (maxim - minim);
        end
    end
end