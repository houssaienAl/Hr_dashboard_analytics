--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    employee_name character varying(255),
    empid integer,
    marriedid integer,
    maritalstatusid integer,
    genderid integer,
    empstatusid integer,
    deptid integer,
    perfscoreid integer,
    fromdiversityjobfairid integer,
    salary double precision,
    termd integer,
    positionid integer,
    "position" character varying(255),
    state character varying(10),
    zip character varying(10),
    dob date,
    sex character(1),
    maritaldesc character varying(255),
    citizendesc character varying(255),
    hispaniclatino character varying(10),
    racedesc character varying(255),
    dateofhire date,
    dateoftermination date,
    termreason character varying(255),
    employmentstatus character varying(255),
    department character varying(255),
    managername character varying(255),
    managerid integer,
    recruitmentsource character varying(255),
    performancescore character varying(50),
    engagementsurvey double precision,
    empsatisfaction integer,
    specialprojectscount integer,
    lastperformancereview_date date,
    dayslatelast30 integer,
    absences integer,
    turnover integer
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: absenteeism_rate_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.absenteeism_rate_view AS
 SELECT department,
    count(empid) AS total_employees,
    sum(absences) AS total_absences,
    (((sum(absences))::numeric * 100.0) / ((count(empid) * 240))::numeric) AS absenteeism_rate_percentage
   FROM public.employees
  WHERE (empstatusid = 1)
  GROUP BY department;


ALTER VIEW public.absenteeism_rate_view OWNER TO postgres;

--
-- Name: average_performance_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.average_performance_view AS
 SELECT department,
    avg(
        CASE
            WHEN (performancescore IS NULL) THEN (0)::double precision
            ELSE (performancescore)::double precision
        END) AS average_performance_score
   FROM public.employees
  WHERE (termd = 0)
  GROUP BY department;


ALTER VIEW public.average_performance_view OWNER TO postgres;

--
-- Name: company_summary_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.company_summary_view AS
 SELECT count(*) AS total_employees,
    round(avg(EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (dob)::timestamp with time zone))), 1) AS average_age,
    round(avg(
        CASE
            WHEN ((performancescore)::text = 'Exceeds'::text) THEN 4
            WHEN ((performancescore)::text = 'Fully Meets'::text) THEN 3
            WHEN ((performancescore)::text = 'Needs Improvement'::text) THEN 2
            WHEN ((performancescore)::text = 'PIP'::text) THEN 1
            ELSE NULL::integer
        END), 1) AS average_performance,
    round(avg(empsatisfaction), 1) AS average_satisfaction
   FROM public.employees
  WHERE (termd = 0);


ALTER VIEW public.company_summary_view OWNER TO postgres;

--
-- Name: employee_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.employee_details AS
 SELECT employee_name AS name,
    department,
    empid AS id,
    dateofhire
   FROM public.employees;


ALTER VIEW public.employee_details OWNER TO postgres;

--
-- Name: employee_distribution_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.employee_distribution_view AS
 SELECT empid,
    employee_name,
    department,
    EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (dob)::timestamp with time zone)) AS age,
    EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (dateofhire)::timestamp with time zone)) AS seniority_years,
        CASE
            WHEN (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (dob)::timestamp with time zone)) < (30)::numeric) THEN 'Under 30'::text
            WHEN ((EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (dob)::timestamp with time zone)) >= (30)::numeric) AND (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (dob)::timestamp with time zone)) <= (50)::numeric)) THEN '30-50'::text
            ELSE 'Above 50'::text
        END AS age_group
   FROM public.employees
  WHERE (termd = 0);


ALTER VIEW public.employee_distribution_view OWNER TO postgres;

--
-- Name: employee_seniority_grouped_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.employee_seniority_grouped_view AS
 SELECT period,
    employee_count
   FROM ( SELECT
                CASE
                    WHEN (subquery.seniority < (3)::numeric) THEN '0-3yrs'::text
                    WHEN ((subquery.seniority >= (3)::numeric) AND (subquery.seniority < (6)::numeric)) THEN '3-6yrs'::text
                    WHEN ((subquery.seniority >= (6)::numeric) AND (subquery.seniority < (9)::numeric)) THEN '6-9yrs'::text
                    ELSE '9yrs+'::text
                END AS period,
            count(*) AS employee_count
           FROM ( SELECT (EXTRACT(year FROM age((CURRENT_DATE)::timestamp with time zone, (employees.dateofhire)::timestamp with time zone)) + (EXTRACT(month FROM age((CURRENT_DATE)::timestamp with time zone, (employees.dateofhire)::timestamp with time zone)) / 12.0)) AS seniority
                   FROM public.employees
                  WHERE (employees.termd = 0)) subquery
          GROUP BY
                CASE
                    WHEN (subquery.seniority < (3)::numeric) THEN '0-3yrs'::text
                    WHEN ((subquery.seniority >= (3)::numeric) AND (subquery.seniority < (6)::numeric)) THEN '3-6yrs'::text
                    WHEN ((subquery.seniority >= (6)::numeric) AND (subquery.seniority < (9)::numeric)) THEN '6-9yrs'::text
                    ELSE '9yrs+'::text
                END) final_subquery
  ORDER BY
        CASE
            WHEN (period = '0-3yrs'::text) THEN 1
            WHEN (period = '3-6yrs'::text) THEN 2
            WHEN (period = '6-9yrs'::text) THEN 3
            WHEN (period = '9yrs+'::text) THEN 4
            ELSE NULL::integer
        END;


ALTER VIEW public.employee_seniority_grouped_view OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_id_seq OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: gender_count_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.gender_count_view AS
 SELECT sum(
        CASE
            WHEN (sex = 'M'::bpchar) THEN 1
            ELSE 0
        END) AS male_count,
    sum(
        CASE
            WHEN (sex = 'F'::bpchar) THEN 1
            ELSE 0
        END) AS female_count
   FROM public.employees
  WHERE (termd = 0);


ALTER VIEW public.gender_count_view OWNER TO postgres;

--
-- Name: gender_distribution_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.gender_distribution_view AS
 SELECT round(((100.0 * (sum(
        CASE
            WHEN (sex = 'M'::bpchar) THEN 1
            ELSE 0
        END))::numeric) / (count(*))::numeric), 1) AS male_percentage,
    round(((100.0 * (sum(
        CASE
            WHEN (sex = 'F'::bpchar) THEN 1
            ELSE 0
        END))::numeric) / (count(*))::numeric), 1) AS female_percentage
   FROM public.employees
  WHERE (termd = 0);


ALTER VIEW public.gender_distribution_view OWNER TO postgres;

--
-- Name: turnover_rate_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.turnover_rate_view AS
 SELECT department,
    count(
        CASE
            WHEN (termd = 1) THEN 1
            ELSE NULL::integer
        END) AS terminated_employees,
    count(*) AS total_employees,
    (((count(
        CASE
            WHEN (termd = 1) THEN 1
            ELSE NULL::integer
        END))::numeric * 100.0) / (count(*))::numeric) AS turnover_rate_percentage
   FROM public.employees
  GROUP BY department;


ALTER VIEW public.turnover_rate_view OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    confirmation_code integer,
    is_verified boolean DEFAULT false
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (id, employee_name, empid, marriedid, maritalstatusid, genderid, empstatusid, deptid, perfscoreid, fromdiversityjobfairid, salary, termd, positionid, "position", state, zip, dob, sex, maritaldesc, citizendesc, hispaniclatino, racedesc, dateofhire, dateoftermination, termreason, employmentstatus, department, managername, managerid, recruitmentsource, performancescore, engagementsurvey, empsatisfaction, specialprojectscount, lastperformancereview_date, dayslatelast30, absences, turnover) FROM stdin;
3	Adinolfi, Wilson  K	10026	0	0	1	1	5	4	0	62506	0	19	Production Technician I	MA	1960	1983-07-10	M	Single	US Citizen	No	White	2011-07-05	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	LinkedIn	Exceeds	4.6	5	0	2019-01-17	0	1	0
4	Ait Sidi, Karthikeyan   	10084	1	1	1	5	3	3	0	104437	1	27	Sr. DBA	MA	2148	1975-05-05	M	Married	US Citizen	No	White	2015-03-30	2016-06-16	career change	Voluntarily Terminated	IT/IS	Simon Roup	4	Indeed	Fully Meets	4.96	3	6	2016-02-24	0	17	1
5	Akinkuolie, Sarah	10196	1	1	0	5	5	3	0	64955	1	20	Production Technician II	MA	1810	1988-09-19	F	Married	US Citizen	No	White	2011-07-05	2012-09-24	hours	Voluntarily Terminated	Production       	Kissy Sullivan	20	LinkedIn	Fully Meets	3.02	3	0	2012-05-15	0	3	1
6	Alagbe,Trina	10088	1	1	0	1	5	3	0	64991	0	19	Production Technician I	MA	1886	1988-09-27	F	Married	US Citizen	No	White	2008-01-07	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Indeed	Fully Meets	4.84	5	0	2019-01-03	0	15	0
7	Anderson, Carol 	10069	0	2	0	5	5	3	0	50825	1	19	Production Technician I	MA	2169	1989-09-08	F	Divorced	US Citizen	No	White	2011-07-11	2016-09-06	return to school	Voluntarily Terminated	Production       	Webster Butler	39	Google Search	Fully Meets	5	4	0	2016-02-01	0	2	1
8	Anderson, Linda  	10002	0	0	0	1	5	4	0	57568	0	19	Production Technician I	MA	1844	1977-05-22	F	Single	US Citizen	No	White	2012-01-09	\N	N/A-StillEmployed	Active	Production       	Amy Dunn	11	LinkedIn	Exceeds	5	5	0	2019-01-07	0	15	0
9	Andreola, Colby	10194	0	0	0	1	4	3	0	95660	0	24	Software Engineer	MA	2110	1979-05-24	F	Single	US Citizen	No	White	2014-11-10	\N	N/A-StillEmployed	Active	Software Engineering	Alex Sweetwater	10	LinkedIn	Fully Meets	3.04	3	4	2019-01-02	0	19	0
10	Athwal, Sam	10062	0	4	1	1	5	3	0	59365	0	19	Production Technician I	MA	2199	1983-02-18	M	Widowed	US Citizen	No	White	2013-09-30	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Employee Referral	Fully Meets	5	4	0	2019-02-25	0	19	0
11	Bachiochi, Linda	10114	0	0	0	3	5	3	1	47837	0	19	Production Technician I	MA	1902	1970-02-11	F	Single	US Citizen	No	Black or African American	2009-07-06	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Diversity Job Fair	Fully Meets	4.46	3	0	2019-01-25	0	4	0
12	Bacong, Alejandro 	10250	0	2	1	1	3	3	0	50178	0	14	IT Support	MA	1886	1988-01-07	M	Divorced	US Citizen	No	White	2015-01-05	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	Indeed	Fully Meets	5	5	6	2019-02-18	0	16	0
13	Baczenski, Rachael  	10252	1	1	0	5	5	3	1	54670	1	19	Production Technician I	MA	1902	1974-01-12	F	Married	US Citizen	Yes	Black or African American	2011-01-10	2017-01-12	Another position	Voluntarily Terminated	Production       	David Stanley	14	Diversity Job Fair	Fully Meets	4.2	4	0	2016-01-30	0	12	1
14	Barbara, Thomas	10242	1	1	1	5	5	3	1	47211	1	19	Production Technician I	MA	2062	1974-02-21	M	Married	US Citizen	Yes	Black or African American	2012-04-02	2016-09-19	unhappy	Voluntarily Terminated	Production       	Kissy Sullivan	20	Diversity Job Fair	Fully Meets	4.2	3	0	2016-05-06	0	15	1
15	Barbossa, Hector	10012	0	2	1	1	3	4	1	92328	0	9	Data Analyst	TX	78230	1988-07-04	M	Divorced	US Citizen	No	Black or African American	2014-11-10	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	Diversity Job Fair	Exceeds	4.28	4	5	2019-02-25	0	9	0
16	Barone, Francesco  A	10265	0	0	1	1	5	3	0	58709	0	19	Production Technician I	MA	1810	1983-07-20	M	Single	US Citizen	No	Two or more races	2012-02-20	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	Google Search	Fully Meets	4.6	4	0	2019-02-14	0	7	0
17	Barton, Nader	10066	0	2	1	5	5	3	0	52505	1	19	Production Technician I	MA	2747	1977-07-15	M	Divorced	US Citizen	No	White	2012-09-24	2017-04-06	Another position	Voluntarily Terminated	Production       	Michael Albert	22	On-line Web application	Fully Meets	5	5	0	2017-03-02	0	1	1
18	Bates, Norman	10061	0	0	1	4	5	3	0	57834	1	19	Production Technician I	MA	2050	1981-10-18	M	Single	US Citizen	No	White	2011-02-21	2017-08-04	attendance	Terminated for Cause	Production       	Kelley Spirea	18	Google Search	Fully Meets	5	4	0	2017-04-05	0	20	0
19	Beak, Kimberly  	10023	1	1	0	2	5	4	0	70131	0	20	Production Technician II	MA	2145	2066-04-17	F	Married	US Citizen	No	White	2016-07-21	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	Employee Referral	Exceeds	4.4	3	0	2019-01-14	0	16	0
20	Beatrice, Courtney 	10055	0	0	0	1	5	3	0	59026	0	19	Production Technician I	MA	1915	1970-10-27	F	Single	Eligible NonCitizen	No	White	2011-04-04	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Google Search	Fully Meets	5	5	0	2019-01-14	0	12	0
21	Becker, Renee	10245	0	0	0	4	3	3	0	110000	1	8	Database Administrator	MA	2026	1986-04-04	F	Single	US Citizen	Yes	White	2014-07-07	2015-09-12	performance	Terminated for Cause	IT/IS	Simon Roup	4	Google Search	Fully Meets	4.5	4	5	2015-01-15	0	8	0
22	Becker, Scott	10277	0	0	1	3	5	3	0	53250	0	19	Production Technician I	MA	2452	1979-04-06	M	Single	US Citizen	No	Asian	2013-07-08	\N	N/A-StillEmployed	Active	Production       	Webster Butler	-1	LinkedIn	Fully Meets	4.2	4	0	2019-01-11	0	13	0
23	Bernstein, Sean	10046	0	0	1	1	5	3	0	51044	0	19	Production Technician I	MA	2072	1970-12-22	M	Single	US Citizen	Yes	White	2012-04-02	\N	N/A-StillEmployed	Active	Production       	Amy Dunn	11	Google Search	Fully Meets	5	3	0	2019-01-14	0	13	0
24	Biden, Lowan  M	10226	0	2	0	1	5	3	0	64919	0	19	Production Technician I	MA	2027	2058-12-27	F	Divorced	US Citizen	No	Asian	2013-08-19	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Indeed	Fully Meets	4.2	3	0	2019-01-10	0	2	0
25	Billis, Helen	10003	1	1	0	1	5	4	0	62910	0	19	Production Technician I	MA	2031	1989-09-01	F	Married	US Citizen	No	White	2014-07-07	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Indeed	Exceeds	5	3	0	2019-02-27	0	19	0
26	Blount, Dianna	10294	0	0	0	1	5	2	0	66441	0	20	Production Technician II	MA	2171	1990-09-21	F	Single	US Citizen	No	White	2011-04-04	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	CareerBuilder	Needs Improvement	2	3	0	2019-02-27	2	3	0
27	Bondwell, Betsy	10267	0	0	0	5	5	3	0	57815	1	20	Production Technician II	MA	2210	2067-01-16	F	Single	US Citizen	No	White	2011-01-10	2014-04-04	career change	Voluntarily Terminated	Production       	Elijiah Gray	16	Google Search	Fully Meets	4.8	5	0	2014-03-04	0	5	1
28	Booth, Frank	10199	0	0	1	4	3	3	0	103613	1	30	Enterprise Architect	CT	6033	2064-07-30	M	Single	US Citizen	No	Black or African American	2014-02-17	2016-02-19	Learned that he is a gangster	Terminated for Cause	IT/IS	Simon Roup	4	LinkedIn	Fully Meets	3.5	5	7	2016-01-10	0	2	0
29	Boutwell, Bonalyn	10081	1	1	0	1	1	3	1	106367	0	26	Sr. Accountant	MA	2468	1987-04-04	F	Married	US Citizen	No	Black or African American	2015-02-16	\N	N/A-StillEmployed	Active	Admin Offices	Brandon R. LeBlanc	3	Diversity Job Fair	Fully Meets	5	4	3	2019-02-18	0	4	0
30	Bozzi, Charles	10175	0	0	1	5	5	3	0	74312	1	18	Production Manager	MA	1901	1970-03-10	M	Single	US Citizen	No	Asian	2013-09-30	2014-08-07	retiring	Voluntarily Terminated	Production       	Janet King	2	Indeed	Fully Meets	3.39	3	0	2014-02-20	0	14	1
31	Brill, Donna	10177	1	1	0	5	5	3	0	53492	1	19	Production Technician I	MA	1701	1990-08-24	F	Married	US Citizen	No	White	2012-04-02	2013-06-15	Another position	Voluntarily Terminated	Production       	David Stanley	14	Google Search	Fully Meets	3.35	4	0	2013-03-04	0	6	1
32	Brown, Mia	10238	1	1	0	1	1	3	1	63000	0	1	Accountant I	MA	1450	1987-11-24	F	Married	US Citizen	No	Black or African American	2008-10-27	\N	N/A-StillEmployed	Active	Admin Offices	Brandon R. LeBlanc	1	Diversity Job Fair	Fully Meets	4.5	2	6	2019-01-15	0	14	0
33	Buccheri, Joseph  	10184	0	0	1	1	5	3	0	65288	0	20	Production Technician II	MA	1013	1983-07-28	M	Single	US Citizen	No	White	2014-09-29	\N	N/A-StillEmployed	Active	Production       	Webster Butler	-1	Google Search	Fully Meets	3.19	3	0	2019-02-01	0	9	0
34	Bugali, Josephine 	10203	0	3	0	3	5	3	1	64375	0	19	Production Technician I	MA	2043	2069-10-30	F	Separated	US Citizen	No	Black or African American	2013-11-11	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	Diversity Job Fair	Fully Meets	3.5	5	0	2019-01-21	0	17	0
35	Bunbury, Jessica	10188	1	1	0	5	6	3	0	74326	1	3	Area Sales Manager	VA	21851	2064-06-01	F	Married	Eligible NonCitizen	No	Black or African American	2011-08-15	2014-08-02	Another position	Voluntarily Terminated	Sales	John Smith	17	Google Search	Fully Meets	3.14	5	0	2013-02-10	1	19	1
36	Burke, Joelle	10107	0	0	0	1	5	3	0	63763	0	20	Production Technician II	MA	2148	1980-03-02	F	Single	US Citizen	No	Black or African American	2012-03-05	\N	N/A-StillEmployed	Active	Production       	Amy Dunn	11	Employee Referral	Fully Meets	4.51	4	0	2019-02-21	0	3	0
37	Burkett, Benjamin 	10181	1	1	1	1	5	3	0	62162	0	20	Production Technician II	MA	1890	1977-08-19	M	Married	US Citizen	No	White	2011-04-04	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Indeed	Fully Meets	3.25	5	0	2019-01-14	0	15	0
38	Cady, Max 	10150	0	0	1	1	4	3	0	77692	0	25	Software Engineering Manager	MA	2184	2066-11-22	M	Single	US Citizen	No	White	2011-08-15	\N	N/A-StillEmployed	Active	Software Engineering	Jennifer Zamora	5	Google Search	Fully Meets	3.84	3	5	2019-01-21	0	4	0
39	Candie, Calvin	10001	0	0	1	1	5	4	0	72640	0	18	Production Manager	MA	2169	1983-08-09	M	Single	US Citizen	No	White	2016-01-28	\N	N/A-StillEmployed	Active	Production       	Janet King	2	Indeed	Exceeds	5	3	0	2019-02-22	0	14	0
40	Carabbio, Judith	10085	0	0	0	1	4	3	0	93396	0	24	Software Engineer	MA	2132	1987-04-05	F	Single	US Citizen	No	White	2013-11-11	\N	N/A-StillEmployed	Active	Software Engineering	Alex Sweetwater	10	Indeed	Fully Meets	4.96	4	6	2019-01-30	0	3	0
41	Carey, Michael  	10115	0	0	1	1	5	3	0	52846	0	19	Production Technician I	MA	1701	1983-02-02	M	Single	US Citizen	No	Black or African American	2014-03-31	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	LinkedIn	Fully Meets	4.43	3	0	2019-02-01	0	14	0
42	Carr, Claudia  N	10082	0	0	0	2	3	3	0	100031	0	27	Sr. DBA	MA	1886	1986-06-06	F	Single	US Citizen	No	Black or African American	2016-06-30	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	LinkedIn	Fully Meets	5	5	6	2019-02-18	0	7	0
43	Carter, Michelle 	10040	0	0	0	1	6	3	0	71860	0	3	Area Sales Manager	VT	5664	2063-05-15	F	Single	US Citizen	No	White	2014-08-18	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Indeed	Fully Meets	5	5	0	2019-01-21	0	7	0
44	Chace, Beatrice 	10067	0	0	0	1	5	3	0	61656	0	19	Production Technician I	MA	2763	2051-01-02	F	Single	US Citizen	No	White	2014-09-29	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	Google Search	Fully Meets	5	4	0	2019-02-12	0	11	0
45	Champaigne, Brian	10108	1	1	1	1	3	3	0	110929	0	5	BI Director	MA	2045	1972-02-09	M	Married	US Citizen	No	White	2016-09-06	\N	N/A-StillEmployed	Active	IT/IS	Jennifer Zamora	5	Indeed	Fully Meets	4.5	5	7	2019-01-15	0	8	0
46	Chan, Lin	10210	0	0	0	1	5	3	0	54237	0	19	Production Technician I	MA	2170	1979-02-12	F	Single	US Citizen	No	White	2014-05-12	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Indeed	Fully Meets	3.3	4	0	2019-02-19	0	11	0
47	Chang, Donovan  E	10154	0	0	1	1	5	3	0	60380	0	19	Production Technician I	MA	1845	1983-08-24	M	Single	US Citizen	No	White	2013-07-08	\N	N/A-StillEmployed	Active	Production       	Webster Butler	-1	LinkedIn	Fully Meets	3.8	5	0	2019-01-14	0	4	0
48	Chigurh, Anton	10200	0	0	1	1	6	3	0	66808	0	3	Area Sales Manager	TX	78207	1970-06-11	M	Single	Eligible NonCitizen	No	Black or African American	2012-05-14	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Employee Referral	Fully Meets	3	5	0	2019-01-19	0	17	0
49	Chivukula, Enola	10240	0	0	0	5	5	3	0	64786	1	19	Production Technician I	MA	1775	1983-08-27	F	Single	US Citizen	No	White	2011-06-27	2015-11-15	relocation out of area	Voluntarily Terminated	Production       	Amy Dunn	11	Indeed	Fully Meets	4.3	4	0	2015-03-10	0	3	1
50	Cierpiszewski, Caroline  	10168	0	0	0	1	5	3	0	64816	0	19	Production Technician I	MA	2044	1988-05-31	F	Single	Non-Citizen	No	Black or African American	2011-10-03	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Indeed	Fully Meets	3.58	5	0	2019-01-30	0	3	0
51	Clayton, Rick	10220	0	0	1	1	3	3	0	68678	0	14	IT Support	MA	2170	1985-09-05	M	Single	US Citizen	No	White	2012-09-05	\N	N/A-StillEmployed	Active	IT/IS	Eric Dougall	6	Indeed	Fully Meets	4.7	3	6	2019-02-27	0	2	0
52	Cloninger, Jennifer	10275	1	1	0	5	5	3	0	64066	1	20	Production Technician II	MA	1752	1981-08-31	F	Married	US Citizen	No	White	2011-05-16	2013-01-07	unhappy	Voluntarily Terminated	Production       	Brannon Miller	12	Google Search	Fully Meets	4.2	5	0	2012-05-03	0	9	1
53	Close, Phil	10269	1	1	1	5	5	3	0	59369	1	20	Production Technician II	MA	2169	1978-11-25	M	Married	US Citizen	No	White	2010-08-30	2011-09-26	career change	Voluntarily Terminated	Production       	David Stanley	14	Indeed	Fully Meets	4.2	4	0	2011-05-04	0	6	1
54	Clukey, Elijian	10029	1	1	1	2	5	4	0	50373	0	19	Production Technician I	MA	2134	1980-08-26	M	Married	US Citizen	No	White	2016-07-06	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Employee Referral	Exceeds	4.1	4	0	2019-02-28	0	5	0
55	Cockel, James	10261	0	0	1	1	5	3	0	63108	0	19	Production Technician I	MA	2452	1977-09-08	M	Single	US Citizen	No	White	2013-07-08	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	Employee Referral	Fully Meets	4.4	5	0	2019-01-14	0	3	0
56	Cole, Spencer	10292	0	0	1	4	5	2	0	59144	1	19	Production Technician I	MA	1880	1979-08-12	M	Single	US Citizen	No	Black or African American	2011-07-11	2016-09-23	performance	Terminated for Cause	Production       	Kissy Sullivan	20	LinkedIn	Needs Improvement	2	3	0	2016-05-01	5	16	0
57	Corleone, Michael	10282	0	2	1	1	5	2	0	68051	0	18	Production Manager	MA	1803	1975-12-17	M	Divorced	US Citizen	No	White	2010-07-20	\N	N/A-StillEmployed	Active	Production       	Janet King	2	CareerBuilder	Needs Improvement	4.13	2	0	2019-01-14	3	3	0
58	Corleone, Vito	10019	0	0	1	1	5	4	0	170500	0	10	Director of Operations	MA	2030	1983-03-19	M	Single	US Citizen	No	Black or African American	2009-01-05	\N	N/A-StillEmployed	Active	Production       	Janet King	2	Indeed	Exceeds	3.7	5	0	2019-02-04	0	15	0
59	Cornett, Lisa 	10094	1	1	0	1	5	3	0	63381	0	19	Production Technician I	MA	2189	1977-03-31	F	Married	US Citizen	Yes	White	2015-01-05	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	Indeed	Fully Meets	4.73	5	0	2019-02-14	0	6	0
60	Costello, Frank	10193	1	1	1	1	3	3	0	83552	0	9	Data Analyst	MA	1810	1986-08-26	M	Married	US Citizen	No	White	2015-03-30	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	Indeed	Fully Meets	3.04	3	6	2019-01-22	0	2	0
61	Crimmings,   Jean	10132	0	0	0	2	5	3	0	56149	0	19	Production Technician I	MA	1821	1987-04-10	F	Single	US Citizen	No	White	2016-07-06	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	LinkedIn	Fully Meets	4.12	5	0	2019-01-28	0	15	0
62	Cross, Noah	10083	0	0	1	1	3	3	0	92329	0	28	Sr. Network Engineer	CT	6278	2065-09-09	M	Single	US Citizen	No	White	2014-11-10	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	Employee Referral	Fully Meets	5	3	4	2019-01-02	0	5	0
63	Daneault, Lynn	10099	0	0	0	1	6	3	0	65729	0	21	Sales Manager	VT	5473	1990-04-19	F	Single	US Citizen	No	White	2014-05-05	\N	N/A-StillEmployed	Active	Sales	Debra Houlihan	15	Indeed	Fully Meets	4.62	4	0	2019-01-24	0	8	0
64	Daniele, Ann  	10212	1	1	0	3	3	3	0	85028	0	28	Sr. Network Engineer	CT	6033	2052-01-18	F	Married	US Citizen	No	White	2014-11-10	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	LinkedIn	Fully Meets	3.1	5	8	2019-02-12	0	19	0
65	Darson, Jene'ya 	10056	1	1	0	1	5	3	0	57583	0	19	Production Technician I	MA	2110	1978-11-05	F	Married	US Citizen	No	White	2012-07-02	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Indeed	Fully Meets	5	3	0	2019-02-25	0	1	0
66	Davis, Daniel	10143	0	0	1	1	5	3	0	56294	0	20	Production Technician II	MA	2458	1979-09-14	M	Single	Eligible NonCitizen	No	Two or more races	2011-11-07	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	LinkedIn	Fully Meets	3.96	4	0	2019-02-27	0	6	0
67	Dee, Randy	10311	1	1	1	1	6	1	0	56991	0	19	Production Technician I	MA	2138	1988-04-15	M	Married	US Citizen	No	White	2018-07-09	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Indeed	Fully Meets	4.3	4	3	2019-01-31	2	2	0
68	DeGweck,  James	10070	1	1	1	5	5	3	0	55722	1	19	Production Technician I	MA	1810	1977-10-31	M	Married	US Citizen	No	White	2011-05-16	2016-06-08	unhappy	Voluntarily Terminated	Production       	Webster Butler	39	Indeed	Fully Meets	5	4	0	2016-04-02	0	14	1
69	Del Bosque, Keyla	10155	0	0	0	1	4	3	0	101199	0	24	Software Engineer	MA	2176	1979-07-05	F	Single	US Citizen	No	Black or African American	2012-01-09	\N	N/A-StillEmployed	Active	Software Engineering	Alex Sweetwater	10	CareerBuilder	Fully Meets	3.79	5	5	2019-01-25	0	8	0
70	Delarge, Alex	10306	0	0	1	1	6	1	0	61568	0	3	Area Sales Manager	AL	36006	1975-11-02	M	Single	US Citizen	No	Two or more races	2014-09-29	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Indeed	PIP	1.93	3	0	2019-01-30	6	5	0
71	Demita, Carla	10100	0	3	0	5	5	3	0	58275	1	20	Production Technician II	MA	2343	2051-02-25	F	Separated	US Citizen	No	Black or African American	2011-04-04	2015-11-04	more money	Voluntarily Terminated	Production       	Kelley Spirea	18	Google Search	Fully Meets	4.62	5	0	2015-05-06	0	1	1
72	Desimone, Carl 	10310	1	1	1	1	5	1	0	53189	0	19	Production Technician I	MA	2061	2067-04-19	M	Married	US Citizen	No	White	2014-07-07	\N	N/A-StillEmployed	Active	Production       	Amy Dunn	11	Indeed	PIP	1.12	2	0	2019-01-31	4	9	0
73	DeVito, Tommy	10197	0	0	1	1	3	3	0	96820	0	4	BI Developer	MA	2045	1983-09-04	M	Single	US Citizen	No	White	2017-02-15	\N	N/A-StillEmployed	Active	IT/IS	Brian Champaigne	13	Indeed	Fully Meets	3.01	5	7	2019-01-23	0	15	0
74	Dickinson, Geoff 	10276	0	0	1	1	5	3	0	51259	0	19	Production Technician I	MA	2180	1982-11-15	M	Single	US Citizen	No	White	2014-05-12	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Indeed	Fully Meets	4.3	4	0	2019-02-19	0	1	0
75	Dietrich, Jenna  	10304	0	0	0	1	6	1	0	59231	0	3	Area Sales Manager	WA	98052	1987-05-14	F	Single	US Citizen	Yes	White	2012-02-20	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Website	PIP	2.3	1	0	2019-01-29	2	17	0
76	DiNocco, Lily 	10284	1	1	0	1	5	2	0	61584	0	19	Production Technician I	MA	2351	1978-12-02	F	Married	US Citizen	No	Black or African American	2013-01-07	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Indeed	Needs Improvement	3.88	4	0	2019-01-18	0	6	0
77	Dobrin, Denisa  S	10207	0	0	0	1	5	3	0	46335	0	19	Production Technician I	MA	2125	1986-10-07	F	Single	US Citizen	Yes	White	2012-04-02	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	CareerBuilder	Fully Meets	3.4	5	0	2019-02-19	0	15	0
78	Dolan, Linda	10133	1	1	0	1	3	3	0	70621	0	14	IT Support	MA	2119	1988-07-18	F	Married	US Citizen	No	White	2015-01-05	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	Employee Referral	Fully Meets	4.11	4	6	2019-02-25	0	16	0
79	Dougall, Eric	10028	0	0	1	1	3	4	0	138888	0	13	IT Manager - Support	MA	1886	1970-07-09	M	Single	US Citizen	No	Black or African American	2014-01-05	\N	N/A-StillEmployed	Active	IT/IS	Jennifer Zamora	5	Indeed	Exceeds	4.3	5	5	2019-01-04	0	4	0
80	Driver, Elle	10006	0	0	0	1	6	4	0	74241	0	3	Area Sales Manager	CA	90007	1988-11-08	F	Single	US Citizen	No	White	2011-01-10	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Indeed	Exceeds	4.77	5	0	2019-01-27	0	14	0
81	Dunn, Amy  	10105	0	0	0	1	5	3	0	75188	0	18	Production Manager	MA	1731	1973-11-28	F	Single	US Citizen	No	White	2014-09-18	\N	N/A-StillEmployed	Active	Production       	Janet King	2	Google Search	Fully Meets	4.52	4	0	2019-01-15	0	4	0
316	houssain	\N	\N	\N	\N	\N	\N	\N	\N	500	\N	\N	\N	\N	\N	\N	F	\N	Tunisia	\N	\N	2025-05-05	\N	\N	\N	Manager	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0
82	Dunne, Amy	10211	1	1	0	1	5	3	0	62514	0	19	Production Technician I	MA	1749	1973-09-23	F	Married	US Citizen	No	White	2010-04-26	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Google Search	Fully Meets	2.9	3	0	2019-01-21	0	6	0
83	Eaton, Marianne	10064	1	1	0	5	5	3	0	60070	1	19	Production Technician I	MA	2343	1991-09-05	F	Married	US Citizen	No	White	2011-04-04	2017-06-06	military	Voluntarily Terminated	Production       	Kissy Sullivan	20	Google Search	Fully Meets	5	3	0	2017-04-09	0	7	1
84	Engdahl, Jean	10247	0	0	1	1	5	3	0	48888	0	19	Production Technician I	MA	2026	1974-05-31	M	Single	US Citizen	No	White	2014-11-10	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	LinkedIn	Fully Meets	4.7	5	0	2019-02-13	0	8	0
85	England, Rex	10235	1	1	1	1	5	3	0	54285	0	19	Production Technician I	MA	2045	1978-08-25	M	Married	US Citizen	No	White	2014-03-31	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	Employee Referral	Fully Meets	4.2	3	0	2019-01-11	0	3	0
86	Erilus, Angela	10299	0	3	0	1	5	1	0	56847	0	20	Production Technician II	MA	2133	1989-08-25	F	Separated	US Citizen	No	White	2014-07-07	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	Indeed	PIP	3	1	0	2019-02-25	2	5	0
87	Estremera, Miguel	10280	0	0	1	4	5	2	0	60340	1	19	Production Technician I	MA	2129	1983-09-02	M	Single	US Citizen	No	White	2012-04-02	2018-09-27	attendance	Terminated for Cause	Production       	Michael Albert	22	Google Search	Needs Improvement	5	4	0	2018-04-12	5	16	0
88	Evensen, April	10296	0	0	0	4	5	2	0	59124	1	19	Production Technician I	MA	2458	1989-05-06	F	Single	US Citizen	No	White	2014-02-17	2018-02-25	no-call, no-show	Terminated for Cause	Production       	Elijiah Gray	16	Google Search	Needs Improvement	2.3	3	0	2017-01-15	5	19	0
89	Exantus, Susan	10290	1	1	0	4	4	2	0	99280	1	24	Software Engineer	MA	1749	1987-05-15	F	Married	US Citizen	No	Black or African American	2011-05-02	2013-06-05	attendance	Terminated for Cause	Software Engineering	Alex Sweetwater	10	Indeed	Needs Improvement	2.1	5	4	2012-08-10	4	19	0
90	Faller, Megan 	10263	1	1	0	1	5	3	0	71776	0	20	Production Technician II	MA	1824	1978-09-22	F	Married	US Citizen	No	Black or African American	2014-07-07	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	LinkedIn	Fully Meets	4.4	5	0	2019-02-22	0	17	0
91	Fancett, Nicole	10136	0	0	0	1	5	3	0	65902	0	20	Production Technician II	MA	2324	1987-09-27	F	Single	US Citizen	No	Black or African American	2014-02-17	\N	N/A-StillEmployed	Active	Production       	Webster Butler	-1	LinkedIn	Fully Meets	4	4	0	2019-01-07	0	7	0
92	Ferguson, Susan	10189	1	1	0	5	5	3	0	57748	1	19	Production Technician I	MA	2176	2055-04-14	F	Married	US Citizen	No	White	2011-11-07	2016-05-17	military	Voluntarily Terminated	Production       	Webster Butler	39	Google Search	Fully Meets	3.13	3	0	2016-02-04	0	16	1
93	Fernandes, Nilson  	10308	1	1	1	1	5	1	0	64057	0	19	Production Technician I	MA	2132	1989-10-18	M	Married	US Citizen	No	White	2015-05-11	\N	N/A-StillEmployed	Active	Production       	Amy Dunn	11	Indeed	PIP	1.56	5	0	2019-01-03	6	15	0
94	Fett, Boba	10309	0	0	1	1	3	1	0	53366	0	15	Network Engineer	MA	2138	1987-06-18	M	Single	US Citizen	No	White	2015-03-30	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	LinkedIn	PIP	1.2	3	6	2019-02-04	3	2	0
95	Fidelia,  Libby	10049	1	1	0	1	5	3	0	58530	0	19	Production Technician I	MA	2155	1981-03-16	F	Married	US Citizen	No	White	2012-01-09	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Google Search	Fully Meets	5	5	0	2019-01-29	0	19	0
96	Fitzpatrick, Michael  J	10093	0	0	1	5	5	3	0	72609	1	20	Production Technician II	MA	2143	1981-10-01	M	Single	US Citizen	Yes	White	2011-05-16	2013-06-24	hours	Voluntarily Terminated	Production       	Amy Dunn	11	Google Search	Fully Meets	4.76	5	0	2013-04-05	0	20	1
97	Foreman, Tanya	10163	1	1	0	5	5	3	0	55965	1	20	Production Technician II	MA	2170	1983-11-08	F	Married	US Citizen	No	White	2011-04-04	2013-01-09	career change	Voluntarily Terminated	Production       	Ketsia Liebig	19	Google Search	Fully Meets	3.66	3	0	2012-01-07	0	6	1
98	Forrest, Alex	10305	1	1	1	1	6	3	0	70187	1	3	Area Sales Manager	MA	2330	1975-07-07	M	Married	US Citizen	No	White	2014-09-29	2018-08-19	Fatal attraction	Terminated for Cause	Sales	Lynn Daneault	21	Employee Referral	PIP	2	5	0	2019-01-28	4	7	0
99	Foss, Jason	10015	0	0	1	1	3	4	0	178000	0	12	IT Director	MA	1460	1980-07-05	M	Single	US Citizen	No	Black or African American	2011-04-15	\N	N/A-StillEmployed	Active	IT/IS	Jennifer Zamora	5	Indeed	Exceeds	5	5	5	2019-01-07	0	15	0
100	Foster-Baker, Amy	10080	1	1	0	1	1	3	0	99351	0	26	Sr. Accountant	MA	2050	1979-04-16	F	Married	US Citizen	no	White	2009-01-05	\N	N/A-StillEmployed	Active	Admin Offices	Board of Directors	9	Other	Fully Meets	5	3	2	2019-02-08	0	3	0
101	Fraval, Maruk 	10258	0	0	1	1	6	3	0	67251	0	3	Area Sales Manager	CT	6050	2063-08-28	M	Single	US Citizen	No	Black or African American	2011-09-06	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	CareerBuilder	Fully Meets	4.3	3	0	2019-01-27	2	7	0
102	Galia, Lisa	10273	0	0	0	1	3	3	0	65707	0	14	IT Support	CT	6040	2068-07-06	F	Single	US Citizen	No	White	2010-05-01	\N	N/A-StillEmployed	Active	IT/IS	Eric Dougall	6	LinkedIn	Fully Meets	4.7	4	5	2019-02-01	0	1	0
103	Garcia, Raul	10111	0	0	1	1	5	3	0	52249	0	19	Production Technician I	MA	1905	1985-09-15	M	Single	US Citizen	Yes	White	2015-03-30	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	Employee Referral	Fully Meets	4.5	3	0	2019-02-18	0	5	0
104	Gaul, Barbara	10257	0	0	0	1	5	3	0	53171	0	19	Production Technician I	MA	2121	1983-12-02	F	Single	US Citizen	Yes	Black or African American	2011-05-16	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	LinkedIn	Fully Meets	4.2	4	0	2019-02-26	0	12	0
105	Gentry, Mildred	10159	1	1	0	1	5	3	0	51337	0	19	Production Technician I	MA	2145	1990-10-01	F	Married	US Citizen	No	Black or African American	2015-03-30	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	LinkedIn	Fully Meets	3.73	3	0	2019-01-16	0	19	0
106	Gerke, Melisa	10122	0	2	0	5	5	3	1	51505	1	19	Production Technician I	MA	2330	1970-05-15	F	Divorced	US Citizen	No	Black or African American	2011-11-07	2016-11-15	hours	Voluntarily Terminated	Production       	Elijiah Gray	16	Diversity Job Fair	Fully Meets	4.24	4	0	2016-04-29	0	2	1
107	Gill, Whitney  	10142	0	4	0	4	6	3	0	59370	1	3	Area Sales Manager	OH	43050	1971-07-10	F	Widowed	US Citizen	No	Black or African American	2014-07-07	2015-09-05	attendance	Terminated for Cause	Sales	John Smith	17	CareerBuilder	Fully Meets	3.97	4	0	2014-01-15	0	7	0
108	Gilles, Alex	10283	1	1	1	5	5	2	1	54933	1	19	Production Technician I	MA	2062	1974-08-09	M	Married	US Citizen	No	Black or African American	2012-04-02	2015-06-25	military	Voluntarily Terminated	Production       	Webster Butler	39	Diversity Job Fair	Needs Improvement	3.97	4	0	2015-01-20	3	15	1
109	Girifalco, Evelyn	10018	0	0	0	1	5	4	0	57815	0	19	Production Technician I	MA	2451	1980-05-08	F	Single	US Citizen	Yes	Two or more races	2014-09-29	\N	N/A-StillEmployed	Active	Production       	Amy Dunn	11	Indeed	Exceeds	3.9	4	0	2019-02-07	0	3	0
110	Givens, Myriam	10255	0	0	0	1	6	3	0	61555	0	3	Area Sales Manager	IN	46204	1989-09-22	F	Single	US Citizen	No	White	2015-02-16	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Indeed	Fully Meets	4.5	5	0	2019-01-25	0	20	0
111	Goble, Taisha	10246	0	0	0	4	3	3	0	114800	1	8	Database Administrator	MA	2127	1971-10-23	F	Single	US Citizen	No	White	2015-02-16	2015-03-15	no-call, no-show	Terminated for Cause	IT/IS	Simon Roup	4	Indeed	Fully Meets	4.6	4	4	2015-01-20	0	10	0
112	Goeth, Amon	10228	1	1	1	1	3	3	0	74679	0	14	IT Support	MA	2135	1989-11-24	M	Married	US Citizen	Yes	White	2015-03-30	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	LinkedIn	Fully Meets	4.3	5	7	2019-01-10	0	20	0
113	Gold, Shenice  	10243	0	0	0	1	5	3	0	53018	0	19	Production Technician I	MA	2451	1992-06-18	F	Single	US Citizen	Yes	White	2013-11-11	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Indeed	Fully Meets	4.3	5	0	2019-02-18	0	7	0
114	Gonzalez, Cayo	10031	0	2	1	1	5	4	1	59892	0	19	Production Technician I	MA	2108	2069-09-29	M	Divorced	US Citizen	No	Black or African American	2011-07-11	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Diversity Job Fair	Exceeds	4.5	4	0	2019-02-18	0	1	0
115	Gonzalez, Juan	10300	1	1	1	5	5	1	1	68898	1	20	Production Technician II	MA	2128	2064-10-12	M	Married	US Citizen	No	Black or African American	2010-04-26	2011-05-30	career change	Voluntarily Terminated	Production       	Brannon Miller	12	Diversity Job Fair	PIP	3	3	0	2011-03-06	3	10	1
116	Gonzalez, Maria	10101	0	3	0	1	3	3	0	61242	0	14	IT Support	MA	2472	1981-04-16	F	Separated	US Citizen	Yes	White	2015-01-05	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	Employee Referral	Fully Meets	4.61	4	5	2019-01-28	0	11	0
117	Good, Susan	10237	1	1	0	3	5	3	0	66825	0	20	Production Technician II	MA	1886	1986-05-25	F	Married	US Citizen	No	White	2014-05-12	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Fully Meets	4.6	3	0	2019-02-07	0	20	0
118	Gordon, David	10051	1	1	1	1	5	3	0	48285	0	19	Production Technician I	MA	2169	1979-05-21	M	Married	US Citizen	No	White	2012-07-02	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Fully Meets	5	3	0	2019-01-14	0	2	0
119	Gosciminski, Phylicia  	10218	0	3	0	3	5	3	0	66149	0	20	Production Technician II	MA	1824	1983-12-08	F	Separated	US Citizen	No	American Indian or Alaska Native	2013-09-30	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	Google Search	Fully Meets	4.4	5	0	2019-02-21	0	1	0
120	Goyal, Roxana	10256	1	1	0	3	5	3	0	49256	0	19	Production Technician I	MA	1864	1974-10-09	F	Married	US Citizen	No	Asian	2013-08-19	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	LinkedIn	Fully Meets	4.1	5	0	2019-02-15	0	3	0
121	Gray, Elijiah  	10098	0	2	1	1	5	3	0	62957	0	18	Production Manager	MA	1752	1981-07-11	M	Divorced	US Citizen	No	White	2015-06-02	\N	N/A-StillEmployed	Active	Production       	Janet King	2	Employee Referral	Fully Meets	4.63	3	0	2019-01-04	0	2	0
122	Gross, Paula	10059	0	2	0	5	5	3	0	63813	1	19	Production Technician I	MA	2176	1983-05-21	F	Divorced	US Citizen	No	White	2011-02-21	2014-01-11	more money	Voluntarily Terminated	Production       	Kelley Spirea	18	CareerBuilder	Fully Meets	5	5	0	2013-06-03	0	17	1
123	Gruber, Hans	10234	1	1	1	1	3	3	0	99020	0	4	BI Developer	MA	2134	1989-06-30	M	Married	US Citizen	No	Black or African American	2017-04-20	\N	N/A-StillEmployed	Active	IT/IS	Brian Champaigne	13	Indeed	Fully Meets	4.2	5	5	2019-01-28	0	8	0
124	Guilianno, Mike	10109	0	0	1	5	6	3	0	71707	1	3	Area Sales Manager	TN	37129	2069-02-09	M	Single	US Citizen	No	Two or more races	2012-03-07	2014-10-31	relocation out of area	Voluntarily Terminated	Sales	John Smith	17	LinkedIn	Fully Meets	4.5	5	0	2013-02-01	0	20	1
125	Handschiegl, Joanne	10125	1	1	0	1	5	3	0	54828	0	19	Production Technician I	MA	2127	1977-03-23	F	Married	US Citizen	No	White	2011-11-28	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	Google Search	Fully Meets	4.2	4	0	2019-02-22	0	13	0
126	Hankard, Earnest	10074	0	0	1	1	5	3	0	64246	0	20	Production Technician II	MA	2155	1988-08-10	M	Single	US Citizen	Yes	White	2013-11-11	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	LinkedIn	Fully Meets	5	3	0	2019-01-08	0	20	0
127	Harrington, Christie 	10097	0	0	0	5	5	3	0	52177	1	19	Production Technician I	MA	2324	2052-08-18	F	Single	US Citizen	No	White	2012-01-09	2015-12-15	retiring	Voluntarily Terminated	Production       	Webster Butler	39	CareerBuilder	Fully Meets	4.64	4	0	2015-05-02	0	8	1
128	Harrison, Kara	10007	1	1	0	1	5	4	0	62065	0	19	Production Technician I	MA	1886	1974-05-02	F	Married	US Citizen	No	White	2014-05-12	\N	N/A-StillEmployed	Active	Production       	Amy Dunn	11	CareerBuilder	Exceeds	4.76	4	0	2019-02-15	0	5	0
129	Heitzman, Anthony	10129	0	0	1	1	5	3	0	46998	0	19	Production Technician I	MA	2149	1984-01-04	M	Single	US Citizen	No	White	2012-08-13	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Google Search	Fully Meets	4.17	4	0	2019-02-11	0	1	0
130	Hendrickson, Trina	10075	0	0	0	5	5	3	0	68099	1	20	Production Technician II	MA	2021	1972-08-27	F	Single	US Citizen	No	White	2011-01-10	2013-06-18	hours	Voluntarily Terminated	Production       	Kelley Spirea	18	CareerBuilder	Fully Meets	5	3	0	2013-01-30	0	15	1
131	Hitchcock, Alfred	10167	1	1	1	1	6	3	0	70545	0	3	Area Sales Manager	NH	3062	1988-09-14	M	Married	US Citizen	No	American Indian or Alaska Native	2014-08-18	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Indeed	Fully Meets	3.6	5	0	2019-01-30	0	9	0
132	Homberger, Adrienne  J	10195	1	1	0	5	5	3	0	63478	1	20	Production Technician II	MA	2445	1984-02-16	F	Married	Non-Citizen	No	White	2011-08-15	2012-04-07	relocation out of area	Voluntarily Terminated	Production       	Michael Albert	30	Indeed	Fully Meets	3.03	5	0	2012-03-05	0	16	1
133	Horton, Jayne	10112	0	0	0	1	3	3	0	97999	0	8	Database Administrator	MA	2493	1984-02-21	F	Single	US Citizen	No	White	2015-03-30	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	Indeed	Fully Meets	4.48	5	6	2019-01-03	0	4	0
134	Houlihan, Debra	10272	1	1	0	1	6	3	0	180000	0	11	Director of Sales	RI	2908	2066-03-17	F	Married	US Citizen	No	White	2014-05-05	\N	N/A-StillEmployed	Active	Sales	Janet King	2	LinkedIn	Fully Meets	4.5	4	0	2019-01-21	0	19	0
135	Howard, Estelle	10182	1	1	0	1	1	3	0	49920	1	2	Administrative Assistant	MA	2170	1985-09-16	F	Married	US Citizen	No	Black or African American	2015-02-16	2015-04-15	no-call, no-show	Terminated for Cause	Admin Offices	Brandon R. LeBlanc	1	Indeed	Fully Meets	3.24	3	4	2015-04-15	0	6	0
136	Hudson, Jane	10248	0	0	0	1	5	3	0	55425	0	19	Production Technician I	MA	2176	1986-06-10	F	Single	US Citizen	No	White	2012-02-20	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	LinkedIn	Fully Meets	4.8	4	0	2019-01-07	0	4	0
137	Hunts, Julissa	10201	0	0	0	2	5	3	0	69340	0	20	Production Technician II	MA	2021	1984-03-11	F	Single	US Citizen	No	White	2016-06-06	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	LinkedIn	Fully Meets	3	5	0	2019-01-18	0	4	0
138	Hutter, Rosalie	10214	0	3	0	2	5	3	0	64995	0	20	Production Technician II	MA	2351	1992-05-07	F	Separated	US Citizen	No	White	2015-06-05	\N	N/A-StillEmployed	Active	Production       	Webster Butler	-1	Indeed	Fully Meets	4.5	3	0	2019-02-14	0	6	0
139	Huynh, Ming	10160	0	2	0	5	5	3	0	68182	1	20	Production Technician II	MA	1742	1976-09-22	F	Divorced	US Citizen	No	White	2011-02-21	2013-04-01	unhappy	Voluntarily Terminated	Production       	Amy Dunn	11	Google Search	Fully Meets	3.72	3	0	2013-02-01	0	18	1
140	Immediato, Walter	10289	1	1	1	5	5	2	0	83082	1	18	Production Manager	MA	2128	1976-11-15	M	Married	US Citizen	No	Asian	2011-02-21	2012-09-24	unhappy	Voluntarily Terminated	Production       	Janet King	2	Indeed	Needs Improvement	2.34	2	0	2012-04-12	3	4	1
141	Ivey, Rose 	10139	0	0	0	1	5	3	0	51908	0	19	Production Technician I	MA	1775	1991-01-28	F	Single	US Citizen	No	White	2013-08-19	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Indeed	Fully Meets	3.99	3	0	2019-01-14	0	14	0
142	Jackson, Maryellen	10227	0	0	0	1	5	3	0	61242	0	19	Production Technician I	MA	2081	1972-09-11	F	Single	US Citizen	No	Black or African American	2012-11-05	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Fully Meets	4.1	3	0	2019-01-17	0	7	0
143	Jacobi, Hannah  	10236	0	2	0	1	5	3	0	45069	0	19	Production Technician I	MA	1778	2066-03-22	F	Divorced	US Citizen	No	White	2013-09-30	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	Employee Referral	Fully Meets	4.3	5	0	2019-02-22	0	7	0
144	Jeannite, Tayana	10009	0	2	0	1	5	4	0	60724	0	20	Production Technician II	MA	1821	1986-11-06	F	Divorced	US Citizen	No	American Indian or Alaska Native	2011-07-05	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	LinkedIn	Exceeds	4.6	4	0	2019-02-25	0	11	0
145	Jhaveri, Sneha  	10060	0	3	0	1	5	3	0	60436	0	19	Production Technician I	MA	2109	2064-04-13	F	Separated	US Citizen	No	White	2014-01-06	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	LinkedIn	Fully Meets	5	5	0	2019-01-21	0	9	0
146	Johnson, George	10034	1	1	1	5	5	4	0	46837	1	19	Production Technician I	MA	2445	2059-08-19	M	Married	US Citizen	No	White	2011-11-07	2018-04-29	more money	Voluntarily Terminated	Production       	Michael Albert	22	CareerBuilder	Exceeds	4.7	4	0	2018-02-14	0	9	1
147	Johnson, Noelle 	10156	1	1	0	3	3	3	0	105700	0	8	Database Administrator	MA	2301	1986-11-07	F	Married	US Citizen	No	Asian	2015-01-05	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	Indeed	Fully Meets	3.75	3	5	2019-02-11	0	2	0
148	Johnston, Yen	10036	0	0	0	1	5	4	0	63322	0	20	Production Technician II	MA	2128	2069-09-08	F	Single	US Citizen	No	White	2014-07-07	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	LinkedIn	Exceeds	4.3	3	0	2019-01-11	0	1	0
149	Jung, Judy  	10138	1	1	0	5	5	3	0	61154	1	19	Production Technician I	MA	2446	1986-04-17	F	Married	US Citizen	No	Black or African American	2011-01-10	2016-04-01	unhappy	Voluntarily Terminated	Production       	Elijiah Gray	16	CareerBuilder	Fully Meets	4	4	0	2016-02-03	0	4	1
150	Kampew, Donysha	10244	0	0	0	5	6	3	0	68999	1	21	Sales Manager	PA	19444	1989-11-11	F	Single	US Citizen	No	White	2011-11-07	2014-04-24	maternity leave - did not return	Voluntarily Terminated	Sales	Debra Houlihan	15	Google Search	Fully Meets	4.5	5	0	2013-03-30	0	2	1
151	Keatts, Kramer 	10192	0	0	1	1	5	3	0	50482	0	19	Production Technician I	MA	1887	1976-01-19	M	Single	US Citizen	No	White	2013-09-30	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	Indeed	Fully Meets	3.07	4	0	2019-01-23	0	10	0
152	Khemmich, Bartholemew	10231	0	0	1	1	6	3	0	65310	0	3	Area Sales Manager	CO	80820	1979-11-27	M	Single	US Citizen	No	White	2013-08-19	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Indeed	Fully Meets	4.3	5	0	2019-01-22	0	13	0
153	King, Janet	10089	1	1	0	1	2	3	0	250000	0	16	President & CEO	MA	1902	2054-09-21	F	Married	US Citizen	Yes	White	2012-07-02	\N	N/A-StillEmployed	Active	Executive Office	Board of Directors	9	Indeed	Fully Meets	4.83	3	0	2019-01-17	0	10	0
154	Kinsella, Kathleen  	10166	1	1	0	5	5	3	0	54005	1	19	Production Technician I	MA	2170	1973-12-08	F	Married	US Citizen	No	White	2011-09-26	2015-06-04	more money	Voluntarily Terminated	Production       	Webster Butler	39	Google Search	Fully Meets	3.6	5	0	2015-03-01	0	16	1
155	Kirill, Alexandra  	10170	1	1	0	5	5	3	0	45433	1	19	Production Technician I	MA	2127	1970-10-08	F	Married	US Citizen	No	White	2011-09-26	2014-01-09	more money	Voluntarily Terminated	Production       	Amy Dunn	11	Google Search	Fully Meets	3.49	4	0	2013-01-30	0	6	1
156	Knapp, Bradley  J	10208	0	0	1	1	5	3	0	46654	0	19	Production Technician I	MA	1721	1977-11-10	M	Single	US Citizen	No	Black or African American	2014-02-17	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	LinkedIn	Fully Meets	3.1	3	0	2019-02-06	0	3	0
157	Kretschmer, John	10176	1	1	1	1	5	3	0	63973	0	19	Production Technician I	MA	1801	1980-02-02	M	Married	US Citizen	No	Asian	2011-01-10	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Indeed	Fully Meets	3.38	3	0	2019-01-21	0	17	0
158	Kreuger, Freddy	10165	0	0	1	1	6	3	1	71339	0	3	Area Sales Manager	NY	10171	2069-02-24	M	Single	US Citizen	Yes	Black or African American	2011-03-07	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Diversity Job Fair	Fully Meets	3.65	5	0	2019-01-17	0	20	0
159	Lajiri,  Jyoti	10113	1	1	1	3	3	3	0	93206	0	28	Sr. Network Engineer	MA	2169	1986-04-23	M	Married	US Citizen	No	White	2014-11-10	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	Employee Referral	Fully Meets	4.46	5	6	2019-01-07	0	7	0
160	Landa, Hans	10092	1	1	1	4	5	3	0	82758	1	18	Production Manager	MA	1890	1972-07-01	M	Married	US Citizen	No	White	2011-01-10	2015-12-12	attendance	Terminated for Cause	Production       	Janet King	2	Employee Referral	Fully Meets	4.78	4	0	2015-02-15	0	9	0
161	Langford, Lindsey	10106	0	2	0	5	5	3	0	66074	1	20	Production Technician II	MA	2090	1979-07-25	F	Divorced	US Citizen	No	Asian	2013-01-07	2014-03-31	Another position	Voluntarily Terminated	Production       	David Stanley	14	Indeed	Fully Meets	4.52	3	0	2014-02-20	0	20	1
162	Langton, Enrico	10052	1	1	1	1	5	3	0	46120	0	19	Production Technician I	MA	2048	1986-12-09	M	Married	US Citizen	No	White	2012-07-09	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Fully Meets	5	5	0	2019-02-04	0	13	0
163	LaRotonda, William  	10038	0	2	1	1	1	3	0	64520	0	1	Accountant I	MA	1460	1984-04-26	M	Divorced	US Citizen	No	Black or African American	2014-01-06	\N	N/A-StillEmployed	Active	Admin Offices	Brandon R. LeBlanc	1	Website	Fully Meets	5	4	4	2019-01-17	0	3	0
164	Latif, Mohammed	10249	1	1	1	5	5	3	0	61962	1	20	Production Technician II	MA	2126	1984-05-09	M	Married	US Citizen	No	White	2012-04-02	2013-04-15	more money	Voluntarily Terminated	Production       	Kissy Sullivan	20	Google Search	Fully Meets	4.9	3	0	2013-02-20	0	20	1
165	Le, Binh	10232	0	0	0	1	3	3	0	81584	0	22	Senior BI Developer	MA	1886	1987-06-14	F	Single	US Citizen	No	Asian	2016-10-02	\N	N/A-StillEmployed	Active	IT/IS	Brian Champaigne	13	Indeed	Fully Meets	4.1	5	7	2019-01-08	0	2	0
166	Leach, Dallas	10087	0	0	0	5	5	3	0	63676	1	19	Production Technician I	MA	1810	1979-01-17	F	Single	US Citizen	No	Asian	2011-09-26	2018-08-19	return to school	Voluntarily Terminated	Production       	Kissy Sullivan	20	CareerBuilder	Fully Meets	4.88	3	0	2017-07-02	0	17	1
167	LeBlanc, Brandon  R	10134	1	1	1	1	1	3	0	93046	0	23	Shared Services Manager	MA	1460	1984-06-10	M	Married	US Citizen	No	White	2016-01-05	\N	N/A-StillEmployed	Active	Admin Offices	Janet King	2	CareerBuilder	Fully Meets	4.1	4	0	2019-01-28	0	20	0
168	Lecter, Hannibal	10251	1	1	1	1	5	3	0	64738	0	19	Production Technician I	MA	1776	1982-09-02	M	Married	US Citizen	No	Asian	2012-05-14	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Google Search	Fully Meets	4.1	3	0	2019-02-22	0	10	0
169	Leruth, Giovanni	10103	0	3	1	1	6	3	0	70468	0	3	Area Sales Manager	UT	84111	1988-12-27	M	Separated	US Citizen	No	Black or African American	2012-04-30	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Website	Fully Meets	4.53	3	0	2019-01-29	0	16	0
170	Liebig, Ketsia	10017	1	1	0	1	5	4	0	77915	0	18	Production Manager	MA	2110	1981-10-26	F	Married	US Citizen	No	White	2013-09-30	\N	N/A-StillEmployed	Active	Production       	Janet King	2	Website	Exceeds	4.1	3	0	2019-01-21	0	11	0
171	Linares, Marilyn 	10186	1	1	0	5	5	3	0	52624	1	19	Production Technician I	MA	1886	1981-03-26	F	Married	US Citizen	No	White	2011-07-05	2018-09-26	unhappy	Voluntarily Terminated	Production       	Michael Albert	22	Indeed	Fully Meets	3.18	4	0	2018-03-02	0	16	1
172	Linden, Mathew	10137	1	1	1	3	5	3	0	63450	0	20	Production Technician II	MA	1770	1979-03-19	M	Married	US Citizen	No	White	2013-07-08	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	LinkedIn	Fully Meets	4	3	0	2019-02-18	0	7	0
173	Lindsay, Leonara 	10008	0	0	0	1	3	4	1	51777	0	14	IT Support	CT	6070	1988-10-05	F	Single	US Citizen	Yes	Black or African American	2011-01-21	\N	N/A-StillEmployed	Active	IT/IS	Eric Dougall	6	Diversity Job Fair	Exceeds	4.64	4	5	2019-01-25	0	14	0
174	Lundy, Susan	10096	0	4	0	5	5	3	0	67237	1	20	Production Technician II	MA	2122	1976-12-26	F	Widowed	US Citizen	No	White	2013-07-08	2016-09-15	more money	Voluntarily Terminated	Production       	Michael Albert	22	LinkedIn	Fully Meets	4.65	4	0	2016-06-10	0	15	1
175	Lunquist, Lisa	10035	0	0	0	1	5	4	0	73330	0	20	Production Technician II	MA	2324	1982-03-28	F	Single	US Citizen	No	Black or African American	2013-08-19	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Indeed	Exceeds	4.2	4	0	2019-02-12	0	19	0
176	Lydon, Allison	10057	1	1	0	3	5	3	0	52057	0	19	Production Technician I	MA	2122	1975-10-22	F	Married	US Citizen	No	Black or African American	2015-02-16	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Website	Fully Meets	5	3	0	2019-01-23	0	6	0
177	Lynch, Lindsay	10004	0	0	0	5	5	4	1	47434	1	19	Production Technician I	MA	1844	1973-02-14	F	Single	US Citizen	Yes	Black or African American	2011-11-07	2015-11-14	Another position	Voluntarily Terminated	Production       	Webster Butler	39	Diversity Job Fair	Exceeds	5	4	0	2015-02-02	0	17	1
178	MacLennan, Samuel	10191	0	4	1	5	5	3	0	52788	1	19	Production Technician I	MA	1938	1972-11-09	M	Widowed	US Citizen	No	White	2012-09-24	2017-09-26	hours	Voluntarily Terminated	Production       	Amy Dunn	11	Indeed	Fully Meets	3.08	4	0	2017-04-01	0	18	1
179	Mahoney, Lauren  	10219	0	0	0	1	5	3	0	45395	0	19	Production Technician I	MA	2189	1986-07-07	F	Single	US Citizen	No	White	2014-01-06	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	LinkedIn	Fully Meets	4.6	4	0	2019-02-26	0	14	0
180	Manchester, Robyn	10077	1	1	0	2	5	3	0	62385	0	20	Production Technician II	MA	2324	1976-08-25	F	Married	US Citizen	No	White	2016-05-11	\N	N/A-StillEmployed	Active	Production       	Webster Butler	-1	LinkedIn	Fully Meets	5	3	0	2019-01-21	0	4	0
181	Mancuso, Karen	10073	1	1	0	5	5	3	0	68407	1	20	Production Technician II	MA	2176	1986-12-10	F	Married	US Citizen	No	Two or more races	2011-07-05	2012-08-19	Another position	Voluntarily Terminated	Production       	Amy Dunn	11	LinkedIn	Fully Meets	5	4	0	2012-07-02	0	16	1
182	Mangal, Debbie	10279	1	1	0	1	5	3	0	61349	0	19	Production Technician I	MA	2451	1974-11-07	F	Married	US Citizen	No	White	2013-11-11	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	LinkedIn	Fully Meets	4.1	3	0	2019-01-22	0	11	0
183	Martin, Sandra	10110	0	0	0	1	4	3	0	105688	0	24	Software Engineer	MA	2135	1987-11-07	F	Single	US Citizen	No	Asian	2013-11-11	\N	N/A-StillEmployed	Active	Software Engineering	Alex Sweetwater	10	Google Search	Fully Meets	4.5	5	4	2019-01-14	0	14	0
184	Maurice, Shana	10053	1	1	0	1	5	3	0	54132	0	19	Production Technician I	MA	2330	1977-11-22	F	Married	US Citizen	No	White	2011-05-31	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	Indeed	Fully Meets	5	4	0	2019-01-10	0	8	0
185	Carthy, B'rigit	10076	0	0	0	1	5	3	0	55315	0	20	Production Technician II	MA	2149	1987-05-21	F	Single	US Citizen	No	Black or African American	2015-03-30	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	LinkedIn	Fully Meets	5	5	0	2019-02-07	0	16	0
186	Mckenna, Sandy	10145	1	1	0	1	5	3	0	62810	0	19	Production Technician I	MA	2184	1987-01-07	F	Married	US Citizen	No	Black or African American	2013-01-07	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	CareerBuilder	Fully Meets	3.93	3	0	2019-01-30	0	20	0
187	McKinzie, Jac	10202	1	1	1	2	6	3	0	63291	0	3	Area Sales Manager	TX	78789	1984-07-01	M	Married	US Citizen	No	Two or more races	2016-07-06	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Website	Fully Meets	3.4	4	0	2019-01-29	0	7	0
188	Meads, Elizabeth	10128	0	0	0	5	5	3	1	62659	1	19	Production Technician I	MA	1760	2068-05-30	F	Single	US Citizen	No	Black or African American	2012-04-02	2016-11-11	Another position	Voluntarily Terminated	Production       	Kelley Spirea	18	Diversity Job Fair	Fully Meets	4.18	4	0	2016-02-05	0	17	1
189	Medeiros, Jennifer	10068	0	0	0	1	5	3	0	55688	0	19	Production Technician I	MA	2346	1976-09-22	F	Single	US Citizen	No	White	2015-03-30	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	CareerBuilder	Fully Meets	5	4	0	2019-01-21	0	10	0
190	Miller, Brannon	10116	0	0	1	1	5	3	0	83667	0	18	Production Manager	MA	2045	1981-08-10	M	Single	US Citizen	yes	Hispanic	2012-08-16	\N	N/A-StillEmployed	Active	Production       	Janet King	2	Indeed	Fully Meets	4.37	3	0	2019-01-14	0	2	0
191	Miller, Ned	10298	0	0	1	5	5	1	0	55800	1	20	Production Technician II	MA	2472	1985-06-29	M	Single	US Citizen	No	White	2011-08-15	2014-09-04	unhappy	Voluntarily Terminated	Production       	Brannon Miller	12	LinkedIn	PIP	3	2	0	2013-01-14	6	6	1
192	Monkfish, Erasumus	10213	1	1	1	1	5	3	0	58207	0	20	Production Technician II	MA	1450	1992-08-17	M	Married	US Citizen	No	White	2011-11-07	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Fully Meets	3.7	3	0	2019-01-08	0	14	0
193	Monroe, Peter	10288	1	1	1	1	3	2	1	157000	0	13	IT Manager - Infra	MA	2134	1986-10-05	M	Married	Eligible NonCitizen	Yes	Black or African American	2012-02-15	\N	N/A-StillEmployed	Active	IT/IS	Jennifer Zamora	5	Diversity Job Fair	Needs Improvement	2.39	3	6	2019-02-22	4	13	0
194	Monterro, Luisa	10025	0	0	0	1	5	4	0	72460	0	20	Production Technician II	MA	2126	1970-04-24	F	Single	US Citizen	No	Black or African American	2013-05-13	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	Indeed	Exceeds	4.7	3	0	2019-01-14	0	1	0
195	Moran, Patrick	10223	0	0	1	3	5	3	1	72106	0	20	Production Technician II	MA	2127	1976-12-03	M	Single	US Citizen	No	Black or African American	2012-01-09	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	Diversity Job Fair	Fully Meets	4.1	4	0	2019-01-31	0	12	0
196	Morway, Tanya	10151	1	1	0	1	3	3	0	52599	0	15	Network Engineer	MA	2048	1979-04-04	F	Married	US Citizen	No	White	2015-02-16	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	CareerBuilder	Fully Meets	3.81	3	6	2019-02-11	0	6	0
197	Motlagh,  Dawn	10254	0	2	0	1	5	3	0	63430	0	19	Production Technician I	MA	2453	1984-07-07	F	Divorced	US Citizen	No	White	2013-04-01	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	LinkedIn	Fully Meets	4.4	4	0	2019-01-17	0	18	0
198	Moumanil, Maliki 	10120	0	3	1	1	5	3	0	74417	0	20	Production Technician II	MA	1460	1974-12-01	M	Separated	US Citizen	No	Black or African American	2013-05-13	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	LinkedIn	Fully Meets	4.29	5	0	2019-01-28	0	11	0
199	Myers, Michael	10216	0	0	1	1	5	3	0	57575	0	19	Production Technician I	MA	1550	1980-04-18	M	Single	US Citizen	No	Asian	2013-07-08	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	LinkedIn	Fully Meets	4.1	4	0	2019-01-22	0	13	0
200	Navathe, Kurt	10079	0	0	1	1	3	3	0	87921	0	22	Senior BI Developer	MA	2056	1970-04-25	M	Single	US Citizen	No	Asian	2017-02-10	\N	N/A-StillEmployed	Active	IT/IS	Brian Champaigne	13	Indeed	Fully Meets	5	3	6	2019-02-25	0	17	0
201	Ndzi, Colombui	10215	0	0	1	5	5	3	1	50470	1	19	Production Technician I	MA	2110	1989-05-02	M	Single	US Citizen	No	Black or African American	2011-09-26	2014-04-04	return to school	Voluntarily Terminated	Production       	Webster Butler	39	Diversity Job Fair	Fully Meets	4.3	3	0	2013-03-02	0	19	1
202	Ndzi, Horia	10185	1	1	1	5	5	3	0	46664	1	19	Production Technician I	MA	2421	1983-03-28	M	Married	US Citizen	No	White	2013-04-01	2016-05-25	more money	Voluntarily Terminated	Production       	Amy Dunn	11	Employee Referral	Fully Meets	3.18	3	0	2016-03-06	0	10	1
203	Newman, Richard 	10063	1	1	1	3	5	3	0	48495	0	19	Production Technician I	MA	2136	1977-04-08	M	Married	US Citizen	No	White	2014-05-12	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	LinkedIn	Fully Meets	5	5	0	2019-02-18	0	11	0
204	Ngodup, Shari 	10037	0	3	0	1	5	4	1	52984	0	19	Production Technician I	MA	1810	2067-06-03	F	Separated	US Citizen	No	Black or African American	2013-04-01	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Diversity Job Fair	Exceeds	4	3	0	2019-02-13	0	12	0
205	Nguyen, Dheepa	10042	0	0	0	1	6	3	0	63695	0	3	Area Sales Manager	GA	30428	1989-03-31	F	Single	US Citizen	No	Two or more races	2013-07-08	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Indeed	Fully Meets	5	5	0	2019-01-25	0	2	0
206	Nguyen, Lei-Ming	10206	0	0	0	1	5	3	0	62061	0	19	Production Technician I	MA	2132	1984-07-07	F	Single	US Citizen	No	White	2013-07-08	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Fully Meets	3.6	5	0	2019-01-02	0	4	0
207	Nowlan, Kristie	10104	0	0	0	1	5	3	0	66738	0	20	Production Technician II	MA	1040	1985-11-23	F	Single	US Citizen	No	White	2014-11-10	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Indeed	Fully Meets	4.53	5	0	2019-01-16	0	5	0
208	O'hare, Lynn	10303	0	0	0	4	5	1	0	52674	1	19	Production Technician I	MA	2152	1980-09-30	F	Single	US Citizen	No	Two or more races	2014-03-31	2018-05-01	performance	Terminated for Cause	Production       	Kissy Sullivan	20	LinkedIn	PIP	2.33	2	0	2018-03-09	6	3	0
209	Oliver, Brooke 	10078	1	1	0	5	5	3	0	71966	1	20	Production Technician II	MA	2492	2052-02-11	F	Married	US Citizen	No	Asian	2012-05-14	2013-08-19	unhappy	Voluntarily Terminated	Production       	Webster Butler	39	LinkedIn	Fully Meets	5	3	0	2013-07-02	0	17	1
210	Onque, Jasmine	10121	0	0	0	1	6	3	0	63051	0	3	Area Sales Manager	FL	33174	1990-05-11	F	Single	US Citizen	Yes	White	2013-09-30	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Indeed	Fully Meets	4.28	3	0	2019-01-25	0	1	0
211	Osturnka, Adeel	10021	1	1	1	1	5	4	0	47414	0	19	Production Technician I	MA	2478	1976-12-11	M	Married	US Citizen	No	White	2013-09-30	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	LinkedIn	Exceeds	5	3	0	2019-02-07	0	13	0
212	Owad, Clinton	10281	0	0	1	1	5	2	0	53060	0	19	Production Technician I	MA	1760	1979-11-24	M	Single	US Citizen	No	Black or African American	2014-02-17	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	LinkedIn	Needs Improvement	4.25	3	0	2019-02-04	4	6	0
213	Ozark, Travis	10041	0	0	1	1	6	3	0	68829	0	3	Area Sales Manager	NC	27229	1982-05-19	M	Single	US Citizen	No	White	2015-01-05	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Website	Fully Meets	5	5	0	2019-01-14	0	18	0
214	Panjwani, Nina	10148	1	1	0	5	5	3	0	63515	1	19	Production Technician I	MA	2351	1979-05-01	F	Married	US Citizen	No	White	2011-02-07	2014-01-12	Another position	Voluntarily Terminated	Production       	Elijiah Gray	16	Google Search	Fully Meets	3.89	4	0	2013-03-04	0	7	1
215	Patronick, Lucas	10005	0	0	1	5	4	4	1	108987	1	24	Software Engineer	MA	1844	1979-02-20	M	Single	US Citizen	No	Black or African American	2011-11-07	2015-09-07	Another position	Voluntarily Terminated	Software Engineering	Alex Sweetwater	10	Diversity Job Fair	Exceeds	5	5	3	2015-08-16	0	13	1
216	Pearson, Randall	10259	1	1	1	5	3	3	0	93093	1	9	Data Analyst	MA	2747	1984-09-05	M	Married	US Citizen	No	White	2014-12-01	2016-05-01	performance	Voluntarily Terminated	IT/IS	Simon Roup	4	Employee Referral	Fully Meets	4.7	4	5	2016-01-16	0	19	1
217	Smith, Martin	10286	0	0	1	5	5	2	0	53564	1	19	Production Technician I	MA	2458	1988-03-17	M	Single	US Citizen	No	Black or African American	2011-01-10	2017-12-28	career change	Voluntarily Terminated	Production       	Webster Butler	39	Google Search	Needs Improvement	3.54	5	0	2017-04-06	4	15	1
218	Pelletier, Ermine	10297	1	1	0	5	5	2	0	60270	1	20	Production Technician II	MA	2472	1989-07-18	F	Married	US Citizen	No	Asian	2011-07-05	2015-09-15	unhappy	Voluntarily Terminated	Production       	Amy Dunn	11	CareerBuilder	Needs Improvement	2.4	5	0	2015-02-06	5	2	1
219	Perry, Shakira	10171	0	0	0	5	5	3	0	45998	1	19	Production Technician I	MA	2176	1986-07-20	F	Single	US Citizen	No	White	2011-05-16	2015-10-25	medical issues	Voluntarily Terminated	Production       	Amy Dunn	11	LinkedIn	Fully Meets	3.45	4	0	2014-05-13	0	5	1
220	Peters, Lauren	10032	1	1	0	5	5	4	0	57954	1	20	Production Technician II	MA	1886	1986-08-17	F	Married	US Citizen	No	White	2011-05-16	2013-02-04	more money	Voluntarily Terminated	Production       	Ketsia Liebig	19	Indeed	Exceeds	4.2	5	0	2013-01-10	0	12	1
221	Peterson, Ebonee  	10130	1	1	0	5	5	3	0	74669	1	18	Production Manager	MA	2030	1977-05-09	F	Married	US Citizen	No	White	2010-10-25	2016-05-18	Another position	Voluntarily Terminated	Production       	Janet King	2	Indeed	Fully Meets	4.16	5	0	2015-03-05	0	6	1
222	Petingill, Shana  	10217	1	1	0	1	5	3	0	74226	0	20	Production Technician II	MA	2050	1979-03-10	F	Married	Eligible NonCitizen	No	Asian	2012-04-02	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	LinkedIn	Fully Meets	4.3	3	0	2019-01-14	0	14	0
223	Petrowsky, Thelma	10016	1	1	0	1	3	4	0	93554	0	9	Data Analyst	MA	1886	1984-09-16	F	Married	US Citizen	No	Black or African American	2014-11-10	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	Employee Referral	Exceeds	4.6	5	7	2019-01-04	0	16	0
224	Pham, Hong	10050	1	1	1	5	5	3	0	64724	1	19	Production Technician I	MA	2451	1988-03-06	M	Married	US Citizen	No	Asian	2011-07-05	2012-11-30	more money	Voluntarily Terminated	Production       	Brannon Miller	12	Google Search	Fully Meets	5	3	0	2012-02-20	0	13	1
225	Pitt, Brad 	10164	0	0	1	1	5	3	0	47001	0	19	Production Technician I	MA	2451	1981-11-23	M	Single	US Citizen	No	White	2007-11-05	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	Google Search	Fully Meets	3.66	3	0	2019-02-25	0	15	0
226	Potts, Xana	10124	1	1	0	1	6	3	0	61844	0	3	Area Sales Manager	KY	40220	1988-08-29	F	Married	US Citizen	No	Black or African American	2012-01-09	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Website	Fully Meets	4.2	5	0	2019-02-01	0	9	0
227	Power, Morissa	10187	0	2	0	5	5	3	0	46799	1	19	Production Technician I	MA	1742	1984-10-15	F	Divorced	Eligible NonCitizen	No	Asian	2011-05-16	2018-06-04	Another position	Voluntarily Terminated	Production       	Kissy Sullivan	20	Google Search	Fully Meets	3.17	4	0	2018-04-02	0	14	1
228	Punjabhi, Louis  	10225	0	0	1	1	5	3	0	59472	0	19	Production Technician I	MA	2109	2061-06-19	M	Single	US Citizen	No	White	2014-01-06	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	Employee Referral	Fully Meets	4.8	3	0	2019-01-07	0	14	0
229	Purinton, Janine	10262	0	2	0	5	5	3	0	46430	1	19	Production Technician I	MA	2474	1970-09-22	F	Divorced	US Citizen	No	White	2012-09-24	2013-06-18	unhappy	Voluntarily Terminated	Production       	Kissy Sullivan	20	Indeed	Fully Meets	4.5	5	0	2013-04-02	0	16	1
230	Quinn, Sean	10131	1	1	1	5	1	3	1	83363	1	23	Software Engineer	MA	2045	1984-11-06	M	Married	Eligible NonCitizen	No	Black or African American	2011-02-21	2015-08-15	career change	Voluntarily Terminated	Software Engineering	Janet King	2	Diversity Job Fair	Fully Meets	4.15	4	0	2014-04-19	0	4	1
231	Rachael, Maggie	10239	1	1	0	1	3	3	0	95920	0	4	BI Developer	MA	2110	1980-05-12	F	Married	US Citizen	No	Black or African American	2016-10-02	\N	N/A-StillEmployed	Active	IT/IS	Brian Champaigne	13	Indeed	Fully Meets	4.4	4	6	2019-02-06	0	10	0
232	Rarrick, Quinn	10152	0	2	1	5	5	3	0	61729	1	19	Production Technician I	MA	2478	1984-12-31	M	Divorced	US Citizen	No	White	2011-09-26	2018-04-07	more money	Voluntarily Terminated	Production       	Michael Albert	22	Indeed	Fully Meets	3.8	5	0	2018-02-04	0	19	1
233	Ren, Kylo	10140	1	1	1	1	6	3	0	61809	0	3	Area Sales Manager	ID	83706	2054-10-12	M	Married	US Citizen	No	White	2014-05-12	\N	N/A-StillEmployed	Active	Sales	John Smith	17	CareerBuilder	Fully Meets	3.98	3	0	2019-01-28	0	4	0
234	Rhoads, Thomas	10058	0	2	1	5	5	3	0	45115	1	19	Production Technician I	MA	2176	1982-07-22	M	Divorced	US Citizen	Yes	White	2011-05-16	2016-01-15	retiring	Voluntarily Terminated	Production       	Elijiah Gray	16	LinkedIn	Fully Meets	5	4	0	2015-03-30	0	11	1
235	Rivera, Haley  	10011	1	1	0	1	5	4	0	46738	0	19	Production Technician I	MA	2171	1973-01-12	F	Married	US Citizen	No	Asian	2011-11-28	\N	N/A-StillEmployed	Active	Production       	Webster Butler	-1	Google Search	Exceeds	4.36	5	0	2019-02-11	0	16	0
236	Roberson, May	10230	0	2	0	5	5	3	0	64971	1	20	Production Technician II	MA	1902	1981-09-05	F	Divorced	Eligible NonCitizen	No	Black or African American	2011-09-26	2011-10-22	return to school	Voluntarily Terminated	Production       	David Stanley	14	Google Search	Fully Meets	4.5	4	0	2011-10-22	0	10	1
237	Robertson, Peter	10224	1	1	1	5	5	3	0	55578	1	20	Production Technician II	MA	2138	1972-07-03	M	Married	US Citizen	No	White	2011-07-05	2012-02-08	Another position	Voluntarily Terminated	Production       	Kissy Sullivan	20	Indeed	Fully Meets	4.2	5	0	2012-01-06	0	13	1
238	Robinson, Alain  	10047	1	1	1	5	5	3	0	50428	1	19	Production Technician I	MA	1420	1974-01-07	M	Married	US Citizen	No	Black or African American	2011-01-10	2016-01-26	attendance	Voluntarily Terminated	Production       	Amy Dunn	11	Indeed	Fully Meets	5	3	0	2015-01-10	0	11	1
239	Robinson, Cherly	10285	1	1	0	4	5	2	0	61422	1	19	Production Technician I	MA	1460	1985-01-07	F	Married	US Citizen	No	White	2011-01-10	2016-05-17	attendance	Terminated for Cause	Production       	Ketsia Liebig	19	Indeed	Needs Improvement	3.6	3	0	2016-04-05	4	16	0
240	Robinson, Elias	10020	0	4	1	1	5	4	0	63353	0	19	Production Technician I	MA	1730	1985-01-28	M	Widowed	US Citizen	No	White	2013-07-08	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Employee Referral	Exceeds	3.6	5	0	2019-02-11	0	4	0
241	Roby, Lori 	10162	1	1	0	1	3	3	0	89883	0	9	Data Analyst	MA	1886	1981-10-11	F	Married	US Citizen	No	White	2015-02-16	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	Employee Referral	Fully Meets	3.69	5	6	2019-02-14	0	15	0
242	Roehrich, Bianca	10149	0	0	0	5	3	3	0	120000	1	29	Principal Data Architect	MA	2703	1973-05-27	F	Single	US Citizen	Yes	White	2015-01-05	2018-11-10	Another position	Voluntarily Terminated	IT/IS	Simon Roup	4	LinkedIn	Fully Meets	3.88	3	7	2018-02-13	0	12	1
243	Roper, Katie	10086	0	0	0	1	3	3	0	150290	0	7	Data Architect	MA	2056	1972-11-21	F	Single	US Citizen	No	Black or African American	2017-01-07	\N	N/A-StillEmployed	Active	IT/IS	Brian Champaigne	13	Indeed	Fully Meets	4.94	3	5	2019-02-06	0	17	0
244	Rose, Ashley  	10054	0	3	0	1	5	3	0	60627	0	19	Production Technician I	MA	1886	1974-12-05	F	Separated	US Citizen	No	White	2014-01-06	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	Website	Fully Meets	5	4	0	2019-01-31	0	8	0
245	Rossetti, Bruno	10065	0	0	1	5	5	3	0	53180	1	19	Production Technician I	MA	2155	1987-03-18	M	Single	US Citizen	No	White	2011-04-04	2018-08-13	Another position	Voluntarily Terminated	Production       	Kissy Sullivan	20	Google Search	Fully Meets	5	5	0	2018-07-02	0	4	1
246	Roup,Simon	10198	0	0	1	1	3	3	0	140920	0	13	IT Manager - DB	MA	2481	1973-04-05	M	Single	US Citizen	No	White	2013-01-20	\N	N/A-StillEmployed	Active	IT/IS	Jennifer Zamora	5	Indeed	Fully Meets	3.6	5	7	2019-02-18	0	13	0
247	Ruiz, Ricardo	10222	0	2	1	5	3	3	1	148999	1	13	IT Manager - DB	MA	1915	2064-01-04	M	Divorced	US Citizen	No	Black or African American	2012-01-09	2015-11-04	hours	Voluntarily Terminated	IT/IS	Jennifer Zamora	5	Diversity Job Fair	Fully Meets	4.3	4	6	2015-01-04	0	8	1
248	Saada, Adell	10126	1	1	0	1	4	3	0	86214	0	24	Software Engineer	MA	2132	1986-07-24	F	Married	US Citizen	No	White	2012-11-05	\N	N/A-StillEmployed	Active	Software Engineering	Alex Sweetwater	10	Indeed	Fully Meets	4.2	3	6	2019-02-13	0	2	0
249	Saar-Beckles, Melinda	10295	0	0	0	2	5	2	1	47750	0	19	Production Technician I	MA	1801	2068-06-06	F	Single	US Citizen	No	Black or African American	2016-07-04	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	Diversity Job Fair	Needs Improvement	2.6	4	0	2019-02-18	5	4	0
250	Sadki, Nore  	10260	0	0	1	5	5	3	0	46428	1	19	Production Technician I	MA	2148	1974-12-21	M	Single	US Citizen	No	White	2009-01-05	2018-07-30	relocation out of area	Voluntarily Terminated	Production       	Michael Albert	22	Google Search	Fully Meets	4.6	5	0	2018-02-05	0	7	1
251	Sahoo, Adil	10233	1	1	1	1	5	3	0	57975	0	20	Production Technician II	MA	2062	1986-04-26	M	Married	US Citizen	No	White	2010-08-30	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	CareerBuilder	Fully Meets	4.1	3	0	2019-01-10	0	13	0
252	Salter, Jason	10229	0	2	1	5	3	3	0	88527	1	9	Data Analyst 	MA	2452	1987-12-17	M	Divorced	US Citizen	No	Black or African American	2015-01-05	2015-10-31	hours	Voluntarily Terminated	IT/IS	Simon Roup	4	LinkedIn	Fully Meets	4.2	3	5	2015-04-20	0	2	1
253	Sander, Kamrin	10169	1	1	0	1	5	3	0	56147	0	19	Production Technician I	MA	2154	1988-07-10	F	Married	US Citizen	No	Black or African American	2014-09-29	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	LinkedIn	Fully Meets	3.51	3	0	2019-02-18	0	2	0
254	Sewkumar, Nori	10071	0	0	0	3	5	3	0	50923	0	19	Production Technician I	MA	2191	1975-03-10	F	Single	US Citizen	No	Asian	2013-09-30	\N	N/A-StillEmployed	Active	Production       	Webster Butler	-1	Google Search	Fully Meets	5	5	0	2019-02-06	0	14	0
255	Shepard, Anita 	10179	1	1	0	1	3	3	0	50750	0	15	Network Engineer	MA	1773	1981-04-14	F	Married	US Citizen	No	White	2014-09-30	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	LinkedIn	Fully Meets	3.31	3	6	2019-01-07	0	7	0
256	Shields, Seffi	10091	1	1	0	1	5	3	0	52087	0	19	Production Technician I	MA	2149	1985-08-24	F	Married	US Citizen	No	White	2013-08-19	\N	N/A-StillEmployed	Active	Production       	Amy Dunn	11	LinkedIn	Fully Meets	4.81	4	0	2019-02-15	0	15	0
257	Simard, Kramer	10178	1	1	1	1	3	3	0	87826	0	9	Data Analyst	MA	2110	1970-02-08	M	Married	US Citizen	Yes	White	2015-01-05	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	Employee Referral	Fully Meets	3.32	3	7	2019-01-14	0	16	0
258	Singh, Nan 	10039	0	0	0	1	1	3	0	51920	0	2	Administrative Assistant	MA	2330	1988-05-19	F	Single	US Citizen	No	White	2015-05-01	\N	N/A-StillEmployed	Active	Admin Offices	Brandon R. LeBlanc	1	Website	Fully Meets	5	3	5	2019-01-15	0	2	0
259	Sloan, Constance	10095	0	0	0	5	5	3	0	63878	1	20	Production Technician II	MA	1851	1987-11-25	F	Single	US Citizen	No	White	2009-10-26	2015-04-08	maternity leave - did not return	Voluntarily Terminated	Production       	Michael Albert	22	CareerBuilder	Fully Meets	4.68	4	0	2015-04-02	0	20	1
260	Smith, Joe	10027	0	0	1	1	5	4	0	60656	0	20	Production Technician II	MA	2045	2063-10-30	M	Single	US Citizen	No	White	2014-09-29	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Indeed	Exceeds	4.3	3	0	2019-01-28	0	4	0
261	Smith, John	10291	0	2	1	1	6	2	1	72992	0	21	Sales Manager	MA	1886	1984-08-16	M	Divorced	US Citizen	No	Black or African American	2014-05-18	\N	N/A-StillEmployed	Active	Sales	Debra Houlihan	15	Diversity Job Fair	Needs Improvement	2.4	4	0	2019-01-16	2	16	0
262	Smith, Leigh Ann	10153	1	1	0	5	1	3	1	55000	1	2	Administrative Assistant	MA	1844	1987-06-14	F	Married	US Citizen	No	Black or African American	2011-09-26	2013-09-25	career change	Voluntarily Terminated	Admin Offices	Brandon R. LeBlanc	1	Diversity Job Fair	Fully Meets	3.8	4	4	2013-08-15	0	17	1
263	Smith, Sade	10157	0	0	0	1	5	3	0	58939	0	19	Production Technician I	MA	2130	2065-02-02	F	Single	US Citizen	No	White	2013-11-11	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Employee Referral	Fully Meets	3.73	3	0	2019-01-24	0	16	0
264	Soto, Julia 	10119	1	1	0	1	3	3	0	66593	0	14	IT Support	MA	2360	1973-03-12	F	Married	US Citizen	No	Black or African American	2011-06-10	\N	N/A-StillEmployed	Active	IT/IS	Eric Dougall	6	LinkedIn	Fully Meets	4.3	3	5	2019-02-08	0	19	0
265	Soze, Keyser	10180	1	1	1	2	3	3	0	87565	0	28	Sr. Network Engineer	MA	1545	1983-02-09	M	Married	US Citizen	No	Asian	2016-06-30	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	LinkedIn	Fully Meets	3.27	4	5	2019-01-14	0	13	0
266	Sparks, Taylor  	10302	1	1	0	1	5	1	0	64021	0	19	Production Technician I	MA	2093	2068-07-20	F	Married	US Citizen	No	White	2012-02-20	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Indeed	PIP	2.4	2	1	2019-02-25	6	20	0
267	Spirea, Kelley	10090	1	1	0	1	5	3	0	65714	0	18	Production Manager	MA	2451	1975-09-30	F	Married	US Citizen	No	White	2012-10-02	\N	N/A-StillEmployed	Active	Production       	Janet King	2	LinkedIn	Fully Meets	4.83	5	0	2019-02-14	0	15	0
268	Squatrito, Kristen	10030	0	2	0	5	5	4	0	62425	1	19	Production Technician I	MA	2359	1973-03-26	F	Divorced	US Citizen	No	White	2013-05-13	2015-06-29	unhappy	Voluntarily Terminated	Production       	David Stanley	14	LinkedIn	Exceeds	4.1	4	0	2015-03-02	0	16	1
269	Stanford,Barbara  M	10278	0	2	0	1	5	3	0	47961	0	19	Production Technician I	MA	2050	1982-08-25	F	Divorced	US Citizen	No	Two or more races	2011-01-10	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	Google Search	Fully Meets	4.1	4	0	2019-02-07	0	9	0
270	Stansfield, Norman	10307	1	1	1	1	6	1	0	58273	0	3	Area Sales Manager	NV	89139	1974-05-09	M	Married	US Citizen	No	White	2014-05-12	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Website	PIP	1.81	2	0	2019-01-17	3	5	0
271	Steans, Tyrone  	10147	0	0	1	1	1	3	0	63003	0	1	Accountant I	MA	2703	1986-09-01	M	Single	US Citizen	No	White	2014-09-29	\N	N/A-StillEmployed	Active	Admin Offices	Brandon R. LeBlanc	1	Indeed	Fully Meets	3.9	5	5	2019-01-18	0	9	0
272	Stoica, Rick	10266	1	1	1	1	5	3	0	61355	0	19	Production Technician I	MA	2301	1985-03-14	M	Married	US Citizen	No	Asian	2014-02-17	\N	N/A-StillEmployed	Active	Production       	Kelley Spirea	18	LinkedIn	Fully Meets	4.7	3	0	2019-01-11	0	4	0
273	Strong, Caitrin	10241	1	1	0	1	6	3	0	60120	0	3	Area Sales Manager	MT	59102	1989-05-12	F	Married	US Citizen	No	Black or African American	2010-09-27	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Indeed	Fully Meets	4.1	4	0	2019-01-31	0	18	0
274	Sullivan, Kissy 	10158	1	1	0	1	5	3	0	63682	0	18	Production Manager	MA	1776	1978-03-28	F	Married	US Citizen	No	Black or African American	2009-01-08	\N	N/A-StillEmployed	Active	Production       	Janet King	2	Indeed	Fully Meets	3.73	4	0	2019-01-24	0	12	0
275	Sullivan, Timothy	10117	1	1	1	1	5	3	0	63025	0	19	Production Technician I	MA	2747	1982-10-07	M	Married	US Citizen	Yes	White	2015-01-05	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	Google Search	Fully Meets	4.36	5	0	2019-01-24	0	10	0
276	Sutwell, Barbara	10209	0	0	0	1	5	3	0	59238	0	19	Production Technician I	MA	2718	2068-08-15	F	Single	Eligible NonCitizen	No	Asian	2012-05-14	\N	N/A-StillEmployed	Active	Production       	Elijiah Gray	16	Indeed	Fully Meets	3.4	5	0	2019-01-31	0	13	0
277	Szabo, Andrew	10024	0	0	1	1	4	4	0	92989	0	24	Software Engineer	MA	2140	1983-05-06	M	Single	US Citizen	No	White	2014-07-07	\N	N/A-StillEmployed	Active	Software Engineering	Alex Sweetwater	10	LinkedIn	Exceeds	4.5	5	5	2019-02-18	0	1	0
278	Tannen, Biff	10173	1	1	1	1	3	3	0	90100	0	4	BI Developer	MA	2134	1987-10-24	M	Married	US Citizen	No	White	2017-04-20	\N	N/A-StillEmployed	Active	IT/IS	Brian Champaigne	13	Indeed	Fully Meets	3.4	3	6	2019-01-02	0	14	0
279	Tavares, Desiree  	10221	1	1	0	5	5	3	1	60754	1	19	Production Technician I	MA	1801	1975-04-03	F	Married	Non-Citizen	No	Black or African American	2009-04-27	2013-04-01	Another position	Voluntarily Terminated	Production       	Webster Butler	39	Diversity Job Fair	Fully Meets	4.5	5	0	2012-02-15	0	11	1
280	Tejeda, Lenora 	10146	1	1	0	5	5	3	0	72202	1	20	Production Technician II	MA	2129	2053-05-24	F	Married	US Citizen	No	White	2011-05-16	2017-07-08	Another position	Voluntarily Terminated	Production       	Elijiah Gray	16	Google Search	Fully Meets	3.93	3	0	2017-04-18	0	3	1
281	Terry, Sharlene 	10161	0	0	0	1	6	3	0	58370	0	3	Area Sales Manager	OR	97756	2065-05-07	F	Single	US Citizen	No	Black or African American	2014-09-29	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Indeed	Fully Meets	3.69	3	0	2019-01-28	0	18	0
282	Theamstern, Sophia	10141	0	0	0	5	5	3	0	48413	1	19	Production Technician I	MA	2066	2065-05-09	F	Single	US Citizen	No	White	2011-07-05	2016-09-05	return to school	Voluntarily Terminated	Production       	Amy Dunn	11	Indeed	Fully Meets	3.98	4	0	2016-03-02	0	1	1
283	Thibaud, Kenneth	10268	0	4	1	5	5	3	0	67176	1	20	Production Technician II	MA	2472	1975-09-16	M	Widowed	US Citizen	No	White	2007-06-25	2010-08-30	military	Voluntarily Terminated	Production       	Webster Butler	39	Other	Fully Meets	4.1	4	0	2010-07-14	0	15	1
284	Tippett, Jeanette	10123	0	2	0	1	5	3	0	56339	0	19	Production Technician I	MA	2093	2067-06-05	F	Divorced	US Citizen	No	Black or African American	2013-02-18	\N	N/A-StillEmployed	Active	Production       	Brannon Miller	12	Indeed	Fully Meets	4.21	5	0	2019-01-14	0	4	0
285	Torrence, Jack	10013	0	3	1	1	6	4	0	64397	0	3	Area Sales Manager	ND	58782	2068-01-15	M	Separated	US Citizen	No	White	2006-01-09	\N	N/A-StillEmployed	Active	Sales	Lynn Daneault	21	Indeed	Exceeds	4.1	3	0	2019-01-04	0	6	0
286	Trang, Mei	10287	0	0	0	1	5	2	0	63025	0	19	Production Technician I	MA	2021	1983-05-16	F	Single	US Citizen	No	White	2014-02-17	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Needs Improvement	2.44	5	0	2019-02-11	4	18	0
287	Tredinnick, Neville 	10044	1	1	1	5	3	3	0	75281	1	15	Network Engineer	MA	1420	1988-05-05	M	Married	US Citizen	No	White	2015-01-05	2016-02-12	medical issues	Voluntarily Terminated	IT/IS	Peter Monroe	7	CareerBuilder	Fully Meets	5	3	5	2015-04-15	0	11	1
288	True, Edward	10102	0	0	1	5	4	3	1	100416	1	24	Software Engineer	MA	2451	1983-06-14	M	Single	Non-Citizen	No	Black or African American	2013-02-18	2018-04-15	medical issues	Voluntarily Terminated	Software Engineering	Alex Sweetwater	10	Diversity Job Fair	Fully Meets	4.6	3	4	2017-02-12	0	9	1
289	Trzeciak, Cybil	10270	0	0	0	5	5	3	0	74813	1	20	Production Technician II	MA	1778	1985-03-15	F	Single	US Citizen	No	White	2011-01-10	2014-07-02	unhappy	Voluntarily Terminated	Production       	Amy Dunn	11	LinkedIn	Fully Meets	4.4	3	0	2014-01-05	0	5	1
290	Turpin, Jumil	10045	1	1	1	1	3	3	0	76029	0	15	Network Engineer	MA	2343	2069-03-31	M	Married	Eligible NonCitizen	No	White	2015-03-30	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	Employee Referral	Fully Meets	5	4	7	2019-01-14	0	8	0
291	Valentin,Jackie	10205	1	1	0	1	6	3	0	57859	0	3	Area Sales Manager	AZ	85006	1991-05-23	F	Married	US Citizen	No	Two or more races	2011-07-05	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Indeed	Fully Meets	2.81	3	0	2019-01-17	0	16	0
292	Veera, Abdellah 	10014	0	2	1	5	5	4	0	58523	1	19	Production Technician I	MA	2171	1987-01-31	M	Divorced	US Citizen	No	White	2012-08-13	2016-02-05	maternity leave - did not return	Voluntarily Terminated	Production       	Kissy Sullivan	20	LinkedIn	Exceeds	4.5	5	0	2016-02-01	0	15	1
293	Vega, Vincent	10144	0	2	1	1	5	3	0	88976	0	17	Production Manager	MA	2169	2068-10-10	M	Divorced	US Citizen	No	White	2011-08-01	\N	N/A-StillEmployed	Active	Production       	Janet King	2	Employee Referral	Fully Meets	3.93	3	0	2019-02-27	0	19	0
294	Villanueva, Noah	10253	0	0	1	1	6	3	0	55875	0	3	Area Sales Manager	ME	4063	1989-07-11	M	Single	US Citizen	No	Asian	2012-03-05	\N	N/A-StillEmployed	Active	Sales	John Smith	17	Website	Fully Meets	4.5	4	0	2019-01-18	0	11	0
295	Voldemort, Lord	10118	1	1	1	4	3	3	0	113999	1	8	Database Administrator	MA	1960	1986-08-07	M	Married	US Citizen	No	Black or African American	2015-02-16	2017-02-22	no-call, no-show	Terminated for Cause	IT/IS	Simon Roup	4	Employee Referral	Fully Meets	4.33	3	7	2017-02-15	0	9	0
296	Volk, Colleen	10022	1	1	0	4	5	4	0	49773	1	19	Production Technician I	MA	2747	1986-06-03	F	Married	US Citizen	No	White	2011-09-26	2016-02-08	gross misconduct	Terminated for Cause	Production       	Kelley Spirea	18	Google Search	Exceeds	4.3	5	0	2015-02-01	0	18	0
297	Von Massenbach, Anna	10183	0	0	0	2	5	3	0	62068	0	19	Production Technician I	MA	2124	1985-04-06	F	Single	US Citizen	No	White	2015-07-05	\N	N/A-StillEmployed	Active	Production       	Michael Albert	22	LinkedIn	Fully Meets	3.21	3	0	2019-01-29	0	7	0
298	Walker, Roger	10190	0	0	1	1	5	3	0	66541	0	20	Production Technician II	MA	2459	1976-02-10	M	Single	US Citizen	No	Black or African American	2014-08-18	\N	N/A-StillEmployed	Active	Production       	Ketsia Liebig	19	Employee Referral	Fully Meets	3.11	5	0	2019-02-12	0	4	0
299	Wallace, Courtney  E	10274	1	1	0	5	5	3	1	80512	1	18	Production Manager	MA	2478	2055-11-14	F	Married	US Citizen	No	Black or African American	2011-09-26	2012-01-02	Another position	Voluntarily Terminated	Production       	Janet King	2	Diversity Job Fair	Fully Meets	4.5	3	0	2012-01-02	0	5	1
300	Wallace, Theresa	10293	0	0	0	5	5	2	0	50274	1	19	Production Technician I	MA	1887	1980-08-02	F	Single	US Citizen	No	White	2012-08-13	2015-09-01	career change	Voluntarily Terminated	Production       	Elijiah Gray	16	CareerBuilder	Needs Improvement	2.5	3	0	2014-09-05	6	13	1
301	Wang, Charlie	10172	0	0	1	1	3	3	0	84903	0	22	Senior BI Developer	MA	1887	1981-07-08	M	Single	US Citizen	No	Asian	2017-02-15	\N	N/A-StillEmployed	Active	IT/IS	Brian Champaigne	13	Indeed	Fully Meets	3.42	4	7	2019-01-04	0	17	0
302	Warfield, Sarah	10127	0	4	0	1	3	3	0	107226	0	28	Sr. Network Engineer	MA	2453	1978-05-02	F	Widowed	US Citizen	No	Asian	2015-03-30	\N	N/A-StillEmployed	Active	IT/IS	Peter Monroe	7	Employee Referral	Fully Meets	4.2	4	8	2019-02-05	0	7	0
303	Whittier, Scott	10072	0	0	1	5	5	3	0	58371	1	19	Production Technician I	MA	2030	1987-05-24	M	Single	US Citizen	Yes	White	2011-01-10	2014-05-15	hours	Voluntarily Terminated	Production       	Webster Butler	39	LinkedIn	Fully Meets	5	5	0	2014-05-15	0	11	1
304	Wilber, Barry	10048	1	1	1	5	5	3	0	55140	1	19	Production Technician I	MA	2324	2065-09-09	M	Married	Eligible NonCitizen	No	White	2011-05-16	2015-09-07	unhappy	Voluntarily Terminated	Production       	Amy Dunn	11	Website	Fully Meets	5	3	0	2015-02-15	0	7	1
305	Wilkes, Annie	10204	0	2	0	5	5	3	0	58062	1	19	Production Technician I	MA	1876	1983-07-30	F	Divorced	US Citizen	No	White	2011-01-10	2012-05-14	Another position	Voluntarily Terminated	Production       	Ketsia Liebig	19	Google Search	Fully Meets	3.6	5	0	2011-02-06	0	9	1
306	Williams, Jacquelyn  	10264	0	0	0	5	5	3	1	59728	1	19	Production Technician I	MA	2109	2069-10-02	F	Single	US Citizen	Yes	Black or African American	2012-01-09	2015-06-27	relocation out of area	Voluntarily Terminated	Production       	Ketsia Liebig	19	Diversity Job Fair	Fully Meets	4.3	4	0	2014-06-02	0	16	1
307	Winthrop, Jordan  	10033	0	0	1	5	5	4	0	70507	1	20	Production Technician II	MA	2045	2058-11-07	M	Single	US Citizen	No	White	2013-01-07	2016-02-21	retiring	Voluntarily Terminated	Production       	Brannon Miller	12	LinkedIn	Exceeds	5	3	0	2016-01-19	0	7	1
308	Wolk, Hang  T	10174	0	0	0	1	5	3	0	60446	0	20	Production Technician II	MA	2302	1985-04-20	F	Single	US Citizen	No	White	2014-09-29	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Fully Meets	3.4	4	0	2019-02-21	0	14	0
309	Woodson, Jason	10135	0	0	1	1	5	3	0	65893	0	20	Production Technician II	MA	1810	1985-05-11	M	Single	US Citizen	No	White	2014-07-07	\N	N/A-StillEmployed	Active	Production       	Kissy Sullivan	20	LinkedIn	Fully Meets	4.07	4	0	2019-02-28	0	13	0
310	Ybarra, Catherine 	10301	0	0	0	5	5	1	0	48513	1	19	Production Technician I	MA	2458	1982-05-04	F	Single	US Citizen	No	Asian	2008-09-02	2015-09-29	Another position	Voluntarily Terminated	Production       	Brannon Miller	12	Google Search	PIP	3.2	2	0	2015-09-02	5	4	1
311	Zamora, Jennifer	10010	0	0	0	1	3	4	0	220450	0	6	CIO	MA	2067	1979-08-30	F	Single	US Citizen	No	White	2010-04-10	\N	N/A-StillEmployed	Active	IT/IS	Janet King	2	Employee Referral	Exceeds	4.6	5	6	2019-02-21	0	16	0
312	Zhou, Julia	10043	0	0	0	1	3	3	0	89292	0	9	Data Analyst	MA	2148	1979-02-24	F	Single	US Citizen	No	White	2015-03-30	\N	N/A-StillEmployed	Active	IT/IS	Simon Roup	4	Employee Referral	Fully Meets	5	3	5	2019-02-01	0	11	0
313	Zima, Colleen	10271	0	4	0	1	5	3	0	45046	0	19	Production Technician I	MA	1730	1978-08-17	F	Widowed	US Citizen	No	Asian	2014-09-29	\N	N/A-StillEmployed	Active	Production       	David Stanley	14	LinkedIn	Fully Meets	4.5	5	0	2019-01-30	0	2	0
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password, confirmation_code, is_verified) FROM stdin;
9	hoss	hoss@gmazsd.com	pass	\N	f
11	hoss 	hosSs@gmazsd.com	HOSS	\N	f
12	SDS	hosDs@gmazsd.com	SD	\N	f
14	hoss	hoqwdqs@sdfs.sdff	fad	\N	f
15	dali	dali@glad.com	dali	\N	f
\.


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_id_seq', 316, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 15, true);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: users users_mail_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_mail_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

