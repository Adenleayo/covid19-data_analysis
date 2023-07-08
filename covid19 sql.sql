--covid19 data set

select * from CovidDeaths
order by 3,4

--count the total rows in the table
select count(*) from CovidDeaths


select * from CovidVaccinations

--count the total rows in the table
select count(*) from CovidVaccinations

select location,date,total_cases,new_cases,new_deaths,total_deaths,population
from CovidDeaths
order by 1,2

--  percentage of total cases vs the total deaths
select location,date,new_cases,new_deaths,total_deaths,total_cases ,cast((total_deaths/total_cases)as int)*100 as death_percentage
from CovidDeaths
where location Like '%Nigeria' and continent is not null
order by 1,2


--percentage of what population got covid
select location,date,new_cases,new_deaths,total_deaths,total_cases,population,(total_cases/population)*100 as infected_percentage
from CovidDeaths
where location like '%Nigeria'
order by 1,2

--global death percentage according to new_cases and new_deaths by location
select date,location,sum(new_cases) as total_new_cases,sum(new_deaths) as total_new_deaths,sum(new_deaths)/sum(new_cases) * 100 as global_death_percentage
from CovidDeaths
where continent is not null
group by location
--order by 1,2

--global death percentage according to new_cases and new_deaths by continet
select continent,sum(new_cases) as total_new_cases,sum(new_deaths) as total_new_deaths,sum(new_deaths)/sum(new_cases) * 100 as global_death_percentage
from CovidDeaths
where continent is not null
group by continent
order by 1,2


--to find infected people in Nigeria
select date,location,total_cases,population,(total_cases/population)* 100
from CovidDeaths
where continent is not null and location = 'Nigeria'

--global infected people
select date,continent,total_cases,population,(total_cases/population)* 100
from CovidDeaths
where continent is not null and location = 'Nigeria'
order by location,date


--countries with the highest infection rate compared to population
select location,max(total_cases) as highest_infection_count,max(total_cases/population)*100 as infected_percentage
from CovidDeaths
group by location
order by 1 

--countries with the highest death count per population 
select location,continent,count(total_deaths) as death_counts
from CovidDeaths
where continent is not null
group by location,continent
order by location

select location,continent,sum(total_deaths) over(partition by continent ORDER BY location) as  death_counts,
row_number() over (partition by continent ORDER BY location)
from CovidDeaths
where continent is not null
group by location

--max total_deaths by continet
select continent,max(total_deaths) as death_counts
from CovidDeaths
where continent is not null
group by continent

--continent with the highest death count
select location, continent,max(total_deaths) as death_counts 
from CovidDeaths
where continent is not null and location is not null
group by continent,location
order by continent,location


select location,continent, max(total_deaths) over(partition by location order by continent) as death_counts,
dense_rank() over (partition by continent order by location) as row_number
from CovidDeaths
where continent is not null and location is not null 
order by continent,location,row_number


--Global numbers

select date,population,sum(new_cases) total_new_cases,sum(total_deaths) / sum(total_cases) * 100 as new_cases from CovidDeaths
group by date,population
order by 1

--preview for covidvaccinations
select * from CovidVaccinations

--count the entire columns for covidvaccination
select count(*) from CovidVaccinations

--using joins
select * from CovidDeaths as dea
join CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date

--total population vs vaccination
select dea.location,dea.continent,dea.date,dea.population,vac.total_vaccinations from CovidDeaths as dea
join CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1



--comparing total total population with the new_vaccination
WITH pop_vs_vac (date,location,continent,population,new_vaccinations,RollingPopleVaccinated)
as 
(
select dea.date, dea.location,dea.continent,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as numeric ))
over (partition by dea.location order by dea.date) As RollingPeopleVaccinated
--rank() over(partition by location)
from covidDeaths as dea
join CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date
where vac.continent is not null
--order by 1,2
)
select *, (RollingPopleVaccinated /population) * 100
from pop_vs_vac


drop table if exists PercentagePeopleVaccinated
CREATE TABLE PercentagePeopleVaccinated
(
date datetime,
location varchar(255),
continent varchar(255),
population numeric,
total_cases numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentagePeopleVaccinated
select dea.date, dea.location,dea.continent,dea.total_cases,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as numeric))
over(partition by dea.location order by dea.date) As RollingPeopleVaccinated
from covidDeaths as dea
join CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date
where vac.continent is not null

select * ,(RollingPeopleVaccinated/population) * 100
from PercentagePeopleVaccinated

--creating a view
CREATE VIEW PeopleVaccinated as 
select a.date, a.location,a.continent,a.total_cases,a.population,b.new_vaccinations,sum(cast(b.total_vaccinations as numeric))
over(partition by a.location order by a.date) As RollingPeopleVaccinated
from covidDeaths as a
join CovidVaccinations as b on a.location = b.location and a.date = b.date
where b.continent is not null
--order by 1,2
select * from PeopleVaccinated

