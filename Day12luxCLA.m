function [lux, CLA] = Day12luxCLA(Red, Green, Blue, id)

[Sm, Vm, M, Vp, V, C] = Day12Constants(id);

lux = V(1)*Red + V(2)*Green + V(3)*Blue;

for i = 1:length(Red)
    RGB = [Red(i) Green(i) Blue(i)];
    Scone(i) = sum(Sm.*RGB);
    Vmaclamda(i) = sum(Vm.*RGB);
    Melanopsin(i) = sum(M.*RGB);
    Vprime(i) = sum(Vp.*RGB);
    
    if(Scone(i) > C(3)*Vmaclamda(i))
        CLA(i) = Melanopsin(i) + C(1)*(Scone(i) - C(3)*Vmaclamda(i)) - C(2)*683*(1 - 2.71^(-(Vprime(i)/(683*6.5))));
    else
        CLA(i) = Melanopsin(i);
    end
    
    CLA(i) = C(4)*CLA(i);
end

end
