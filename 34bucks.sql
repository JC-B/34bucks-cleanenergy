CREATE TABLE bucks34analysis
    AS
        SELECT
            name_st,
            DECODE(pows.type,NULL,0,1) exitingpowplant,
            DECODE(pows.type,NULL,'None',pows.type) exitingpowplanttype,
            SUM(
                nvl(hh_t,0)
            ) hh_t,
            SUM(
                nvl(light_elec,0)
            ) light_elec,
            SUM(
                nvl(light_kero,0)
            ) light_kero,
            SUM(
                nvl(light_cand,0)
            ) light_cand,
            SUM(
                nvl(light_batt,0)
            ) light_batt,
            SUM(
                nvl(light_sol,0)
            ) light_sol,
            SUM(
                nvl(com_mob,0)
            ) com_mob,
            SUM(
                nvl(com_int,0)
            ) com_int,
            SUM(
                nvl(pop_t,0)
            ) pop_t,
            MAX(mean_hhsize) mean_hhsize,
            SUM(usuact_10ab_t) activity,
            SUM(usuact_10ab_govemp_t) + SUM(gd.usuact_10ab_priemp_t) + SUM(gd.usuact_10ab_empyr_t) + SUM(usuact_10ab_ownacc_t) paying_today,
            SUM(usuact_10ab_unpfam_t) + SUM(gd.usuact_10ab_seekw_t) + SUM(gd.usuact_10ab_stu_t) can_pay_in_future,
            MIN(reg.min_latt) min_latt,
            MAX(reg.max_latt) max_latt,
            MIN(reg.min_longt) min_longt,
            MAX(reg.min_longt) max_longt
        FROM
            gd,
            (
                SELECT
                    TRIM(location) location,
                    MAX(type) type
                FROM
                    powstations
                GROUP BY
                    TRIM(location)
            ) pows,
            (
                SELECT
                    TRIM(region) region,
                    MIN(latt) min_latt,
                    MAX(latt) max_latt,
                    MIN(longt) min_longt,
                    MAX(longt) max_longt
                FROM
                    populationlocation
                GROUP BY
                    TRIM(region)
            ) reg
        WHERE
            TRIM(gd.name_st) = pows.location (+)
        AND
            TRIM(gd.name_st) = reg.region (+)
        GROUP BY
            name_st,
            DECODE(pows.type,NULL,0,1),
            DECODE(pows.type,NULL,'None',pows.type);
            
SELECT
    name_st,
    exitingpowplant,
    exitingpowplanttype,
    round( (light_elec / hh_t) * 100,2) light_elec,
    round( (light_sol / hh_t) * 100,2) light_sol,
    round( (light_kero + light_cand + light_batt) / hh_t * 100,2) light_convert_hh,
    round( (light_kero / hh_t) * 100,2) light_kero_hh,
    round( (light_cand / hh_t) * 100,2) light_cand_hh,
    round( (light_batt / hh_t) * 100,2) light_batt_hh,
    light_elec light_elec1_hh,
    light_sol light_sol1_hh,
    (light_kero + light_cand + light_batt)  light_convert1_hh,
    light_kero light_kero1_hh,
    light_cand light_cand1_hh,
    light_batt light_batt1_hh,
    round( (activity / pop_t) * 100,2) activity_levl,
    round( (paying_today / pop_t) * 100,2) paying_today,
    round( (can_pay_in_future / pop_t) * 100,2) can_pay_in_future,
    round( (com_mob / pop_t) * 100,2) mob_coverage, 
    paying_today paying_today1,
    can_pay_in_future can_pay_in_future1,
    com_mob mob_coverage1   
FROM
    bucks34analysis;

-- Average Region Household number
select min(pop_t), max(pop_t), sum(pop_t)/15 from bucks34analysis
;

select min(hh_t), max(hh_t), sum(hh_t)/15 from bucks34analysis
;


-- select (3351994 / 250) * 800000 - 50
SELECT
    name_st,
    pop_t,
    round( (light_kero + light_cand + light_batt) / hh_t * 100,2) light_convert,
    round( (paying_today / pop_t) * 100,2) paying_today,
    round( (can_pay_in_future / pop_t) * 100,2) can_pay_in_future,
    round( (activity / pop_t) * 100,2) activity_levl,
    round( (com_mob / pop_t) * 100,2) mob_coverage,
    (light_kero + light_cand + light_batt)*20 + (light_kero + light_cand + light_batt)*100 - 500000 as avg_roi_solarpanels,
    (pop_t / 250) * 800000 - (pop_t * 30) * 12  avg_roi_mini_grid_perregion_annual
FROM
    bucks34analysis
WHERE
    exitingpowplant = 0
