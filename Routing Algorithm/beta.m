function battery = beta(batt)
if batt > 80
  battery =1;
elseif batt >60
    battery= 2;
elseif batt >40
    battery = 3;
elseif batt >20
    battery =4;
else
    battery = 5;
end
end
