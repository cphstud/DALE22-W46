#sp 1
SELECT  district from city where name in ("Stanley");

#sp 2
select language, name from Country
join CountryLanguage on country.code=CountryLanguage.CountryCode
where name like "%oe%"
order by 2;

#sp 3 
select code from country where name like "Sri%";

# sp 4
select min(surfacearea) from country;

select name,surfacearea from Country
where SurfaceArea in (select min(surfacearea) from country);


#sp 5
select count(*) as "cities", co.name from city ci, country co
where ci.countrycode=co.code
group by co.name
order by 1 desc;

#sp 6
select cl.language, cl.percentage,co.name, co.population from CountryLanguage cl, country co
where cl.CountryCode=co.code
and cl.language like "Pash%"
order by 2 desc;

# sp 7
select co.name,sum(ci.population) as "sum pop"from city ci, country co
where ci.countrycode=co.code
#and co.name like "Den%"
group by co.name
order by 1 desc;

#sp 8 Sprog i nassau?
select cl.language,ci.name,co.name from countrylanguage cl, city ci, Country Co
where ci.countrycode=co.Code
and co.code=cl.countrycode
and ci.name like "Nassa%"
order by 2;

# sp 9 Højest life-expect
Select lifeexpectancy, name from Country
where LifeExpectancy in (select max(lifeexpectancy) from country);

# sp 10 Flere indb end Rusland?
select name, population from country 
where population > (select population from country 
					where name like "Rus%")
order by 2;
