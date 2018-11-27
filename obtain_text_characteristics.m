function [ caracteristiques ] = obtain_text_characteristics( I )
    %binaritzem imatge
    I = I<180;
    %Obtenim les BB de les lletres
    LlistaLletres = regionprops(I, 'Perimeter', 'Area', 'BoundingBox', 'Centroid');
    caracteristiques = [];
    for i = 1:30
        %obtenim la BB de la lletra
        BoundingBoxLletra = LlistaLletres(i).BoundingBox;  
        %augmentem els marcs
        BoundingBoxLletra = BoundingBoxLletra + [-1 -1 1 1];
        %obtenim la imatge de la lletra
        %imcrop(Imatge, [xmin ymin width height]);
        Illetra = imcrop(I, BoundingBoxLletra);
        
        %calcular 8 caracteristiques de forma o area del joc de caracteristiques
        carac = obtaincharacteristics(Illetra, LlistaLletres(i));
        %afegim el valor a la variable global
        caracteristiques = [caracteristiques; carac];
    end
    
    %Normalitzar les caracteristiques perque totes tinguin un rang similar (entre 0 i 1)
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

