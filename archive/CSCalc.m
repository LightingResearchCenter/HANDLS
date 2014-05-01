function CS = CSCalc(CLA)
%CSCALC Calculate CS value from CLA

CS = .7*(1 - (1./(1 + (CLA/355.7).^(1.1026))));

end