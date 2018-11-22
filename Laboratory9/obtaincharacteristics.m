function [ carac ] = obtaincharacteristics( I, Area )
%obtaincharacteristics obtains the characteristics of an image

    %Numero de forats de la lletra
    %obtenim el nombre de components connexes blanques de la imatge
    %original
    CC = bwconncomp(not(I), 8);
    %treiem el fons com a forat
    car_num_forats = CC.NumObjects -1; 
    
    %Percentatge de pixels negres dins la BB
    %normalitzem l'area amb la mida de la imatge
    [f c] = size(I);
    car_area = Area/(f*c);
    
    %{
    % simplified polygonal boundary of a BW image
    idxlists = CC.PixelIdxList;
    pixels = idxlists{1};
    [F,C] = ind2sub(size(BW), pixels);
    % exterior boundary
    k = boundary([F,C],1); % loose factor = 0.15 
    % reduce polygonal
    [RF,RC] = reducem(F(k),C(k),5); % tolerance = 5 degrees
    %plot boundary
    %imshow(128*uint8(BW));hold
    %plot(RC,RF,'LineWidth',8);
    
    %}
    
    %Poligon mes llarg en relacio al perimetre
    
    %Inclunació del poligon mes llarg en relacio al perimetre
    
    %Perimetre de la lletra
    
    %Area de la lletra
    
    %Obtenim el resultat
    carac = [car_num_forats car_area];
end

