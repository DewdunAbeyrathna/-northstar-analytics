-- Customer Complaint Analysis - Most common complaints
SELECT 
    complaint_type,
    COUNT(*) AS number_of_complaints,
    ROUND(AVG(compensation_amount), 2) AS avg_compensation_paid,
    ROUND(AVG(resolution_days), 1) AS avg_days_to_resolve,
    COUNT(CASE WHEN status = 'Open' THEN 1 END) AS still_open
FROM complaints
GROUP BY complaint_type
ORDER BY number_of_complaints DESC;


-- Zone Performance Analysis - Which zones are failing most?
SELECT 
    o.pickup_zone,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) AS failed_count,
    SUM(CASE WHEN d.delivery_status = 'Delayed' THEN 1 ELSE 0 END) AS delayed_count,
    ROUND(100 * SUM(CASE WHEN d.delivery_status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS fail_percentage
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY o.pickup_zone
ORDER BY fail_percentage DESC;


--Exp
SELECT 
    CASE 
        WHEN dr.years_experience < 2 THEN 'Beginner (0-2 years)'
        WHEN dr.years_experience BETWEEN 2 AND 5 THEN 'Intermediate (2-5 years)'
        ELSE 'Experienced (5+ years)'
    END AS experience_level,
    COUNT(*) AS total_deliveries,
    ROUND(100 * AVG(CASE WHEN d.delivery_status = 'OnTime' THEN 1 ELSE 0 END), 2) AS on_time_percentage,
    ROUND(AVG(dr.driver_rating), 2) AS average_driver_rating,
    ROUND(AVG(d.customer_rating_post_delivery), 2) AS average_customer_rating
FROM drivers dr
JOIN deliveries d ON dr.driver_id = d.driver_id
GROUP BY 
    CASE 
        WHEN dr.years_experience < 2 THEN 'Beginner (0-2 years)'
        WHEN dr.years_experience BETWEEN 2 AND 5 THEN 'Intermediate (2-5 years)'
        ELSE 'Experienced (5+ years)'
    END
ORDER BY on_time_percentage DESC;


--Battery
SELECT 
    'Critical (below 60%)' AS battery_status,
    COUNT(*) AS number_of_vehicles,
    ROUND(AVG(battery_health_pct), 1) AS avg_battery_percent
FROM vehicles
WHERE battery_health_pct < 60

UNION ALL

SELECT 
    'Warning (60-80%)' AS battery_status,
    COUNT(*) AS number_of_vehicles,
    ROUND(AVG(battery_health_pct), 1) AS avg_battery_percent
FROM vehicles
WHERE battery_health_pct >= 60 AND battery_health_pct < 80

UNION ALL

SELECT 
    'Good (80%+)' AS battery_status,
    COUNT(*) AS number_of_vehicles,
    ROUND(AVG(battery_health_pct), 1) AS avg_battery_percent
FROM vehicles
WHERE battery_health_pct >= 80

UNION ALL

SELECT 
    'Unknown' AS battery_status,
    COUNT(*) AS number_of_vehicles,
    NULL AS avg_battery_percent
FROM vehicles
WHERE battery_health_pct IS NULL;


-- Hub Performance Analysis
SELECT 
    h.hub_name,
    h.zone,
    COUNT(*) AS deliveries_handled,
    ROUND(100 * AVG(CASE WHEN d.delivery_status = 'OnTime' THEN 1 ELSE 0 END), 2) AS on_time_percentage,
    ROUND(AVG(d.manual_route_override_count), 1) AS avg_route_overrides,
    ROUND(AVG(d.customer_rating_post_delivery), 2) AS avg_customer_rating
FROM hubs h
JOIN deliveries d ON h.hub_id = d.hub_id
GROUP BY h.hub_name, h.zone
ORDER BY on_time_percentage ASC;


-- Profitability by Zone
SELECT 
    o.pickup_zone,
    COUNT(*) AS total_orders,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(SUM(d.fuel_or_charge_cost), 2) AS total_fuel_cost,
    ROUND(SUM(o.order_value) - SUM(d.fuel_or_charge_cost), 2) AS net_profit,
    ROUND(100 * (SUM(o.order_value) - SUM(d.fuel_or_charge_cost)) / SUM(o.order_value), 2) AS profit_margin_percentage
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
GROUP BY o.pickup_zone
ORDER BY profit_margin_percentage ASC;


-- Average Delivery Duration by Zone
SELECT 
    o.pickup_zone,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(EXTRACT(HOUR FROM (d.delivery_completed_at - d.dispatch_time)) * 60 +
              EXTRACT(MINUTE FROM (d.delivery_completed_at - d.dispatch_time))), 1) AS avg_delivery_minutes,
    ROUND(AVG(d.route_distance_km), 1) AS avg_distance_km,
    ROUND(AVG(d.fuel_or_charge_cost), 2) AS avg_fuel_cost
FROM orders o
JOIN deliveries d ON o.order_id = d.order_id
WHERE d.delivery_completed_at IS NOT NULL
GROUP BY o.pickup_zone
ORDER BY avg_delivery_minutes DESC;


-- Monthly Complaint Trends
SELECT 
    TO_CHAR(created_at, 'YYYY-MM') AS month,
    complaint_type,
    COUNT(*) AS complaint_count
FROM complaints
GROUP BY TO_CHAR(created_at, 'YYYY-MM'), complaint_type
ORDER BY month DESC, complaint_count DESC;



-- Drivers Using Most Manual Route Overrides
SELECT 
    dr.driver_id,
    dr.base_zone,
    dr.years_experience,
    COUNT(*) AS deliveries_done,
    SUM(d.manual_route_override_count) AS total_overrides,
    ROUND(AVG(d.manual_route_override_count), 1) AS avg_overrides_per_delivery,
    ROUND(100 * AVG(CASE WHEN d.delivery_status = 'OnTime' THEN 1 ELSE 0 END), 2) AS on_time_percentage
FROM drivers dr
JOIN deliveries d ON dr.driver_id = d.driver_id
GROUP BY dr.driver_id, dr.base_zone, dr.years_experience
HAVING SUM(d.manual_route_override_count) > 0
ORDER BY avg_overrides_per_delivery DESC;


-- Master Summary Statistics
SELECT 'Total Orders' AS metric, COUNT(*) AS value FROM orders
UNION ALL
SELECT 'Total Deliveries', COUNT(*) FROM deliveries
UNION ALL
SELECT 'Failed Deliveries', COUNT(*) FROM deliveries WHERE delivery_status = 'Failed'
UNION ALL
SELECT 'Delayed Deliveries', COUNT(*) FROM deliveries WHERE delivery_status = 'Delayed'
UNION ALL
SELECT 'On-Time Deliveries', COUNT(*) FROM deliveries WHERE delivery_status = 'OnTime'
UNION ALL
SELECT 'On-Time Rate (%)', ROUND(100 * COUNT(CASE WHEN delivery_status = 'OnTime' THEN 1 END) / COUNT(*), 2) FROM deliveries
UNION ALL
SELECT 'Total Complaints', COUNT(*) FROM complaints
UNION ALL
SELECT 'Open Complaints', COUNT(*) FROM complaints WHERE status = 'Open'
UNION ALL
SELECT 'Avg Compensation ($)', ROUND(AVG(compensation_amount), 2) FROM complaints WHERE compensation_amount IS NOT NULL
UNION ALL
SELECT 'Total Drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'Total Vehicles', COUNT(*) FROM vehicles
UNION ALL
SELECT 'Vehicles Needing Repair', COUNT(*) FROM vehicles WHERE maintenance_status IN ('InRepair', 'Scheduled')
UNION ALL
SELECT 'Avg Driver Experience (years)', ROUND(AVG(years_experience), 1) FROM drivers
UNION ALL
SELECT 'Avg Driver Rating', ROUND(AVG(driver_rating), 2) FROM drivers;