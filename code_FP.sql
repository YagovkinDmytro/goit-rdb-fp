-- 1. Завантажте дані:
-- Створіть схему pandemic у базі даних за допомогою SQL-команди.
-- Оберіть її як схему за замовчуванням за допомогою SQL-команди.
-- Імпортуйте дані за допомогою Import wizard.
-- infectious_cases.csv

use pandemic;
select * from infectious_cases;
select * from infectious_cases_normalized;

-- 2. Нормалізуйте таблицю infectious_cases. Збережіть у цій же схемі дві таблиці з нормалізованими даними.

create table entity_code (
id int auto_increment primary key,
entity text,
code text
);

insert into entity_code (entity, code)
select distinct infectious_cases.Entity,
    infectious_cases.Code
from pandemic.infectious_cases;

create table infectious_cases_normalized (
id int auto_increment primary key,
entity_code_id int,
Year int,
Number_yaws text,
polio_cases int, 
cases_guinea_worm int, 
Number_rabies text, 
Number_malaria text, 
Number_hiv text, 
Number_tuberculosis text, 
Number_smallpox text, 
Number_cholera_cases text,
foreign key (entity_code_id) references entity_code(id)
);

insert into infectious_cases_normalized ( 
entity_code_id,
Year,
Number_yaws,
polio_cases,
cases_guinea_worm,
Number_rabies,
Number_malaria,
Number_hiv,
Number_tuberculosis,
Number_smallpox,
Number_cholera_cases)
select 
entity_code.id,
Year,
Number_yaws,
polio_cases,
cases_guinea_worm,
Number_rabies,
Number_malaria,
Number_hiv,
Number_tuberculosis,
Number_smallpox,
Number_cholera_cases
from infectious_cases
join entity_code on infectious_cases.Entity = entity_code.entity and infectious_cases.Code = entity_code.code;

-- 3. Проаналізуйте дані:
-- Для кожної унікальної комбінації Entity та Code або їх id порахуйте середнє, мінімальне, максимальне значення та суму для атрибута Number_rabies.
-- Врахуйте, що атрибут Number_rabies може містити порожні значення '' — вам попередньо необхідно їх відфільтрувати.
-- Результат відсортуйте за порахованим середнім значенням у порядку спадання.
-- Оберіть тільки 10 рядків для виведення на екран.

select
entity as country,
code,
round(avg(Number_rabies), 2) as average_number_rabies,
round(min(Number_rabies), 2) as min_number_rabies,
round(max(Number_rabies), 2) as max_number_rabies,
round(sum(Number_rabies), 2) as total_number_rabies
from infectious_cases_normalized
inner join entity_code on entity_code.id = infectious_cases_normalized.entity_code_id
where Number_rabies != ''
group by entity_code_id
order by avg(Number_rabies) desc
limit 10;

-- 4. Побудуйте колонку різниці в роках.
-- Для оригінальної або нормованої таблиці для колонки Year побудуйте з використанням вбудованих SQL-функцій:
-- атрибут, що створює дату першого січня відповідного року,
-- атрибут, що дорівнює поточній даті,
-- атрибут, що дорівнює різниці в роках двох вищезгаданих колонок.

select
infectious_cases_normalized.id,
entity as country,
makedate(Year, 1) as full_date,
curdate() as `current_date`,
timestampdiff(YEAR, makedate(Year, 1), curdate()) as diff_years
from infectious_cases_normalized
inner join entity_code on entity_code.id = infectious_cases_normalized.entity_code_id;

-- 5. Побудуйте власну функцію.
-- Створіть і використайте функцію, що будує такий же атрибут, як і в попередньому завданні: 
-- функція має приймати на вхід значення року, 
-- а повертати різницю в роках між поточною датою та датою, 
-- створеною з атрибута року (1996 рік → '1996-01-01').

use pandemic;
drop function if exists Year_diff;

delimiter // 

create function Year_diff(input_year int)
returns int
deterministic
no sql
begin
    declare result int;
    declare year_now int;
    set year_now = year(now());
    set result = year_now - input_year;
    return result;
end //

delimiter ;

select
infectious_cases_normalized.id,
entity as country,
Year_diff(year) as diff_years
from infectious_cases_normalized
inner join entity_code on entity_code.id = infectious_cases_normalized.entity_code_id;











