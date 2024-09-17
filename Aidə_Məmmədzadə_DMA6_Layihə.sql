-- 1. Abonentlərin yaş qrupuna görə və cinsiyyətə görə bölgüsünü göstər:
SELECT
    CASE
        WHEN trunc(months_between(sysdate, birth_date) / 12) < 19              THEN
            '18dən az'
        WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 19 AND 30 THEN
            '18-30'
        WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 31 AND 50 THEN
            '31-50'
        ELSE
            '50+'
    END                   yash_qrup,
    gender                cins,
    COUNT(subscribers_id) say
FROM
    subscribers
GROUP BY
    gender,
    CASE
            WHEN trunc(months_between(sysdate, birth_date) / 12) < 19              THEN
                '18dən az'
            WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 19 AND 30 THEN
                '18-30'
            WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 31 AND 50 THEN
                '31-50'
            ELSE
                '50+'
    END
ORDER BY
    3 DESC;
    
--2.Hər abonent üçün son ödəniş tarixini və məbləğini göstər: 
SELECT
    sub.name          ad,
    surname           soyad,
    MAX(payment_date) son_odenis_tarixi,
    amount            odenis,
    ptype.name        odenis_usulu
FROM
         subscribers sub
    JOIN payments            pay ON sub.subscribers_id = pay.subscribers_id
    JOIN payment_method_type ptype ON pay.payment_type_id = ptype.payment_type_id
GROUP BY
    sub.name,
    surname,
    amount,
    ptype.name
ORDER BY
    1;
    
-- 3.Aktiv xidmətlər üzrə abonentlərin sayını və ümumi ödəniş məbləğini göstər: 
SELECT
    service_name                     xidmetin_adi,
    COUNT(DISTINCT s.subscribers_id) AS akriv_abonent_sayi,
    SUM(p.amount)                    AS umumi_odenis_meblegi
FROM
         subscribers s
    JOIN calls    c ON s.subscribers_id = c.caller_id
    JOIN services srv ON c.service_id = srv.service_id
    JOIN payments p ON s.subscribers_id = p.subscribers_id
                       AND status = 'ACTIVE'
GROUP BY
    service_name
ORDER BY
    2 DESC,
    3 DESC;
    
-- 4.Hər abonent üçün edilən zənglərin sayını və ümumi zəng müddətini göstər: 
SELECT
    name               ad,
    surname            soyad,
    COUNT(call_id)     zeng_sayi,
    SUM(call_duration) umumi_zeng_muddeti,
    call_type          zeng_tipi
FROM
         subscribers s
    JOIN calls c ON s.subscribers_id = c.caller_id
GROUP BY
    name,
    surname,
    call_type
ORDER BY
    1;  
    
--5.Hər abonent üçün tarifə görə aylıq ödədikləri məbləği və zənglərin sayını göstər:
SELECT
    s.name         ad,
    s.surname      soyad,
    tariff_name    tarifin_adi,
    amount         ayliq_mebleg,
    COUNT(call_id) zeng_sayi
FROM
         subscribers s
    JOIN calls               c ON s.subscribers_id = c.caller_id
    JOIN services            sr ON c.service_id = sr.service_id
    JOIN tariff_informations ti ON ti.tariff_id = sr.tariff_id
    JOIN payments            p ON s.subscribers_id = p.subscribers_id
GROUP BY
    s.name,
    s.surname,
    tariff_name,
    amount
ORDER BY
    1;
    
    
--6.Zənglərin növünə görə abonentlərin sayını və ümumi zəng müddətini göstər:
SELECT
    ctype.name                zeng_novu,
    COUNT(DISTINCT caller_id) abonent_sayi,
    SUM(call_duration)        umumi_zeng_muddeti
FROM
         calls c
    JOIN subscribers s ON s.subscribers_id = c.caller_id
    JOIN call_type   ctype ON c.call_type_id = ctype.call_type_id
GROUP BY
    ctype.name
ORDER BY
    2,
    3;
    
--7.Hər tarif üzrə abonentlərin orta yaşını göstər:   
SELECT
    tariff_name                                                 tarifin_adi,
    trunc(AVG(trunc(months_between(sysdate, birth_date) / 12))) orta_yas
FROM
         subscribers s
    JOIN calls               c ON s.subscribers_id = c.caller_id
    JOIN services            sr ON c.service_id = sr.service_id
    JOIN tariff_informations ti ON ti.tariff_id = sr.tariff_id
GROUP BY
    tariff_name
ORDER BY
    2; 
    
--8.Son 6 ayda edilən ödənişlərin və xidmətlərin sayını abonentlər üzrə göstər.
SELECT
    s.name                ad,
    s.surname             soyad,
    COUNT(srv.service_id) xidmetin_sayi,
    SUM(p.amount)         son_6ay_odenis_meblegi
FROM
         subscribers s
    JOIN calls    c ON s.subscribers_id = c.caller_id
    JOIN services srv ON c.service_id = srv.service_id
    JOIN payments p ON s.subscribers_id = p.subscribers_id
WHERE
    payment_date BETWEEN (
        SELECT
            add_months(MAX(payment_date),
                       - 6)
        FROM
            payments
    ) AND (
        SELECT
            MAX(payment_date)
        FROM
            payments
    )
GROUP BY
    s.name,
    s.surname,
    payment_date;
    
--9.Hər şikayət növü üzrə həll olunma müddətinin orta dəyərini və şikayət sayını göstər:
SELECT
    complaint_type_name                           şikayət,
    COUNT(complaint_id)                           şikayət_sayı,
    round(AVG(resolution_date - submission_date)) orta_hellolma_gunu
FROM
         complaints_and_support_requests csr
    JOIN complaint_type ct ON ct.complaint_type_id = csr.complaint_type_id
GROUP BY
    complaint_type_name
ORDER BY
    3;
    
--10. Hər abonent üçün son 12 ayda göndərilən SMS-lərin sayını və SMS məzmununu göstər:
SELECT
    *
FROM
    sms_informations;

SELECT
    name          ad,
    surname       soyad,
    COUNT(sms_id) sms_sayi,
    sms_content   sms_mezmunu
FROM
         subscribers s
    JOIN sms_informations sinfo ON s.subscribers_id = sinfo.sender_id
WHERE
    sms_date BETWEEN (
        SELECT
            add_months(MAX(sms_date),
                       - 12)
        FROM
            sms_informations
    ) AND (
        SELECT
            MAX(sms_date)
        FROM
            sms_informations
    )
GROUP BY
    name,
    surname,
    sms_content
ORDER BY
    1;
        
--11.Hər abonent üçün edilən zənglərin ümumi müddətini və ödəniş məlumatlarını göstər:    
SELECT
    s.name,
    surname,
    SUM(call_duration) umumi_zeng_muddeti,
    SUM(amount)        umumi_mebleg,
    pt.name            odenis_novu
FROM
    subscribers         s
    LEFT JOIN calls               c ON s.subscribers_id = c.caller_id
    JOIN payments            p ON s.subscribers_id = p.subscribers_id
    JOIN payment_method_type pt ON p.payment_type_id = pt.payment_type_id
GROUP BY
    s.name,
    surname,
    pt.name
ORDER BY
    3,
    4;
    
--12. Hər tarif üzrə abonentlərin aylıq ödədikləri məbləğin orta dəyərini və zənglərin sayını göstər:
SELECT
    tariff_name    tarifin_adi,
    AVG(amount)    orta_mebleg,
    COUNT(call_id) zeng_sayi
FROM
         subscribers s
    JOIN calls               c ON s.subscribers_id = c.caller_id
    JOIN services            sr ON c.service_id = sr.service_id
    JOIN tariff_informations ti ON ti.tariff_id = sr.tariff_id
    JOIN payments            p ON s.subscribers_id = p.subscribers_id
GROUP BY
    tariff_name
ORDER BY
    3;
    
--13. Hər abonent üçün son 12 ayda göndərilən SMS-lərin məzmununu və göndərilən SMS növlərini göstər:
SELECT
    s.name      ad,
    s.surname   soyad,
    sms_content sms_mezmunu,
    sms.name    sms_novu
FROM
         subscribers s
    JOIN sms_informations sinfo ON s.subscribers_id = sinfo.sender_id
    JOIN sms_types        sms ON sms.sms_type_id = sinfo.sms_type_id
WHERE
    sms_date BETWEEN (
        SELECT
            add_months(MAX(sms_date),
                       - 12)
        FROM
            sms_informations
    ) AND (
        SELECT
            MAX(sms_date)
        FROM
            sms_informations
    )
ORDER BY
    1,
    3,
    4;
    
-- 14. Hər abonent üçün son 6 ayda edilən ödənişlərin məbləğini və xidmətlərin sayını göstər:
SELECT
    s.name        ad,
    surname       soyad,
    COUNT(srv.service_id),
    SUM(p.amount) son_6ay_odenis_meblegi
FROM
         subscribers s
    JOIN calls    c ON s.subscribers_id = c.caller_id
    JOIN services srv ON c.service_id = srv.service_id
    JOIN payments p ON s.subscribers_id = p.subscribers_id
WHERE
    p.payment_date BETWEEN (
        SELECT
            add_months(MAX(payment_date),
                       - 6)
        FROM
            payments
    ) AND (
        SELECT
            MAX(payment_date)
        FROM
            payments
    )
GROUP BY
    s.name,
    surname
ORDER BY
    3 DESC,
    4 DESC; 
    
-- 15. Hər abonent üçün ödənişlər və şikayətlərin məbləğini göstər:
SELECT
    name                ad,
    surname             soyad,
    SUM(amount)         umumi_odenis,
    COUNT(complaint_id) şikayətlərin_sayı
FROM
    complaints_and_support_requests csr
    RIGHT JOIN subscribers                     s ON csr.subscribers_id = s.subscribers_id
    RIGHT JOIN payments                        p ON p.subscribers_id = s.subscribers_id
GROUP BY
    name,
    surname
ORDER BY
    3 DESC,
    4 DESC;
    
-- 16. Hər tarif üzrə abonentlərin yaş qruplarına görə və aylıq ödədikləri məbləğin orta dəyərini göstər:
SELECT
    tariff_name tarifin_adi,
    CASE
        WHEN trunc(months_between(sysdate, birth_date) / 12) < 19              THEN
            '18dən az'
        WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 19 AND 30 THEN
            '18-30'
        WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 31 AND 50 THEN
            '31-50'
        ELSE
            '50+'
    END         yash_qrup,
    AVG(amount) orta_mebleg
FROM
         subscribers s
    JOIN calls               c ON s.subscribers_id = c.caller_id
    JOIN services            sr ON c.service_id = sr.service_id
    JOIN tariff_informations ti ON ti.tariff_id = sr.tariff_id
    JOIN payments            p ON s.subscribers_id = p.subscribers_id
GROUP BY
    tariff_name,
    CASE
            WHEN trunc(months_between(sysdate, birth_date) / 12) < 19              THEN
                '18dən az'
            WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 19 AND 30 THEN
                '18-30'
            WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 31 AND 50 THEN
                '31-50'
            ELSE
                '50+'
    END
ORDER BY
    2 DESC;

-- 17. Hər abonentin ümumi ödədiyi məbləği və onların ödədikləri məbləğin tariflərin ortalama ödəmə məbləğindən yüksək olub olmadığını göstərən sorğu:
SELECT
    s.name      ad,
    surname     soyad,
    SUM(amount) umumi_mebleg,
    monthly_subscription,
    CASE
        WHEN SUM(amount) < (
            SELECT
                AVG(monthly_subscription)
            FROM
                tariff_informations
        ) THEN
            'Az'
        ELSE
            'Yüksək'
    END         muqayise
FROM
         subscribers s
    JOIN calls               c ON s.subscribers_id = c.caller_id
    JOIN services            sr ON c.service_id = sr.service_id
    JOIN tariff_informations ti ON ti.tariff_id = sr.tariff_id
    JOIN payments            p ON s.subscribers_id = p.subscribers_id
GROUP BY
    s.name,
    surname,
    monthly_subscription
ORDER BY
    3;
    
-- 18. Hər abonentin zənglərin ümumi müddətini və onların zəng müddətinin abonentin yaş qrupunun ortalama zəng müddətindən 
SELECT
    name               ad,
    surname            soyad,
    SUM(call_duration) umumi_zeng_muddeti,
    AVG(call_duration) ortalama_zeng_muddeti,
    CASE
        WHEN trunc(months_between(sysdate, birth_date) / 12) < 19              THEN
            '18dən az'
        WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 19 AND 30 THEN
            '18-30'
        WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 31 AND 50 THEN
            '31-50'
        ELSE
            '50+'
    END                yas_qrup,
    CASE
        WHEN SUM(call_duration) > AVG(call_duration) THEN
            'Çox'
        WHEN SUM(call_duration) < AVG(call_duration) THEN
            'Az'
        ELSE
            'Eyni'
    END                muqayise
FROM
         subscribers s
    JOIN calls c ON s.subscribers_id = c.caller_id
GROUP BY
    name,
    surname,
    CASE
            WHEN trunc(months_between(sysdate, birth_date) / 12) < 19              THEN
                '18dən az'
            WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 19 AND 30 THEN
                '18-30'
            WHEN trunc(months_between(sysdate, birth_date) / 12) BETWEEN 31 AND 50 THEN
                '31-50'
            ELSE
                '50+'
    END
ORDER BY
    3;