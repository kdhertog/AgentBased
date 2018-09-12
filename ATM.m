aircraft_count=40;
airspace_size=200;
aircraft=Aircraft.empty;

for i=1:aircraft_count
    aircraft(i)=Aircraft(rand*200,rand*200);
end

manouvre=Manouvre(aircraft,[airspace_size, airspace_size]);
f= figure;
airspace=Airspace(f,[airspace_size airspace_size],aircraft);
manouvre.run(airspace);

